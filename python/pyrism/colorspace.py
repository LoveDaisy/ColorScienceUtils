import numpy as np
from typing import Union, Optional

from . import common

"""
This module defines various colorspaces used in color science, including RGB, YCbCr, CMYK, Lab, XYZ, etc.
Colorspaces can be categorized as absolute and universal, such as XYZ, or relative and defined by 'anchors' in absolute spaces, such as RGB.
Some colorspaces are smaller than others, for example, sRGB is smaller than AdobeRGB.
Certain colorspaces are closely associated with each other, like YCbCr and RGB, where each YCbCr space is tied to an associated RGB space.

Note: This module is part of the `pyrism` package for color science.
"""


# Similar to ffmpeg's enum AVColorSpace. 'alias' are all in lower cases.
COLORSPACE_NAMES = {
    'Linear': {
        'short': 'Linear',
        'alias': ['linear', ]
    },
    'sRGB': {
        'short': 'sRGB',
        'alias': ['srgb', ]
    },
    'AdobeRGB': {
        'short': 'ARGB',
        'alias': ['argb', 'adobergb', ]
    },
    'BT.709': {
        'short': '709',
        'alias': ['709', 'bt709', 'bt.709', ]
    },
    'BT.2020NCL': {
        'short': '2020NCL',
        'alias': ['2020', 'bt2020', 'bt.2020', '2020ncl', 'bt2020ncl', 'bt.2020ncl', ]
    },
    'DisplayP3': {
        'short': 'P3D65',
        'alias': ['p3', 'p3d65', 'd65p3', 'displayp3', ]
    },
    'DCIP3': {
        'short': 'P3DCI',
        'alias': ['p3dci', 'dcip3', ]
    },
}

COLORSPACE_CANONICAL_NAME_MAP = {a: n for n, v in COLORSPACE_NAMES.items() for a in v['alias']}


class WhitePoint(object):
    """White point.

    This class represents a white point in color spaces. A white point is defined by its name and its XYZ coordinates,
    which are normalized so that the Y coordinate is 1.

    Properties:
    - name: The name of the white point, such as D65, D60, DCI, E, etc.
    - xyz: The XYZ coordinates of the white point, represented as [x, y, z].

    Note: The XYZ coordinates are normalized so that the Y coordinate is 1.

    Example:
    ```python
    wp = WhitePoint('D65')
    print(wp.name)  # Output: D65
    print(wp.xyz)   # Output: [0.3127, 0.3290, 0.3583]
    ```
    """

    def __init__(self, wp: Union[str, 'WhitePoint'] = 'D65') -> None:
        # Copy construct
        if isinstance(wp, WhitePoint):
            self.name = wp.name
            self.xyz = wp.xyz.copy()

        # Construct from a string
        elif isinstance(wp, str):
            self.name = wp.upper()
            if self.name == 'D65':
                xy = [0.3127, 0.3290]
            elif self.name == 'D60':
                xy = [0.32168, 0.33767]
            elif self.name == 'DCI':
                xy = [0.314, 0.351]
            elif self.name == 'E':
                xy = [1/3, 1/3]
            else:
                raise ValueError(f'white point name {wp} cannot recognize!')
            self.xyz = np.array([xy[0], xy[1], 1.0 - xy[0] - xy[1]]) / xy[1]
        else:
            raise TypeError('wrong type for input argument wp!')

    def __eq__(self, __o: object) -> bool:
        if not (__o, WhitePoint):
            return False
        return self.name == __o.name


class TransferFunction(object):
    """Transfer functions.

    This class represents transfer functions used in color spaces. Transfer functions are mathematical functions
    that convert linear signals to non-linear signals (forward function) and non-linear signals back to linear signals
    (inverse function).

    Properties:
    - name: The name of the transfer function, such as sRGB, AdobeRGB, etc.
    - trc: The forward transfer function.
    - inv_trc: The inverse transfer function.

    Note:
    - The transfer functions supported are 'sRGB', 'AdobeRGB', 'BT.709', 'BT.2020', 'DisplayP3', 'DCIP3', and 'Linear'.
    - The 'Linear' transfer function does not apply any transformation.

    Example:
    ```python
    tf = TransferFunction('sRGB')
    result = tf(0.5)  # Apply the forward transfer function to a single value
    inverse_result = tf.inverse(result)  # Apply the inverse transfer function
    ```
    """

    @staticmethod
    def __single_gamma(x: float, g: float, a: float, b: float, k: float) -> float:
        if abs(x) < b:
            return x * k
        else:
            return x / abs(x) * (abs(x) ** g * (1 + a) - a)

    @staticmethod
    def __single_inv_gamma(x: float, g: float, a: float, b: float, k: float) -> float:
        if abs(x) < b * k:
            return x / k
        else:
            return x / abs(x) * ((abs(x) + a) / (1 + a)) ** (1 / g)

    @staticmethod
    def __array_gamma(x: np.ndarray, g: float, a: float, b: float, k: float) -> np.ndarray:
        idx0 = x < b
        idx1 = np.logical_not(idx0)
        y = np.zeros_like(x)
        y[idx0] = x[idx0] * k
        y[idx1] = np.sign(x[idx1]) * (np.abs(x[idx1]) ** (1 / g) * (1 + a) - a)
        return y

    @staticmethod
    def __array_inv_gamma(x: np.ndarray, g: float, a: float, b: float, k: float) -> np.ndarray:
        idx0 = x < b * k
        idx1 = np.logical_not(idx0)
        y = np.zeros_like(x)
        y[idx0] = x[idx0] / k
        y[idx1] = np.sign(x[idx1]) * ((np.abs(x[idx1]) + a) / (1 + a)) ** g
        return y

    @staticmethod
    def __gamma(x: Union[float, np.ndarray], g: float, a: float,
                b: Optional[float] = None, k: Optional[float] = None) -> Union[float, np.ndarray]:
        if not b:
            b = ((1 + a) * (1 - g) / a) ** (-1 / g)
        if not k:
            k = (1 + a) * b ** (g - 1)

        if isinstance(x, float):
            return TransferFunction.__single_gamma(x, a, b, g, k)
        elif isinstance(x, np.ndarray):
            return TransferFunction.__array_gamma(x, a, b, g, k)
        else:
            raise TypeError('Input should be float or np.ndarray!')

    @staticmethod
    def __inv_gamma(x: Union[float, np.ndarray], g: float, a: float,
                    b: Optional[float] = None, k: Optional[float] = None) -> Union[float, np.ndarray]:
        if not b:
            b = ((1 + a) * (1 - g) / a) ** (-1 / g)
        if not k:
            k = (1 + a) * b ** (g - 1)

        if isinstance(x, float):
            return TransferFunction.__single_inv_gamma(x, g, a, b, k)
        elif isinstance(x, np.ndarray):
            return TransferFunction.__array_inv_gamma(x, g, a, b, k)
        else:
            raise TypeError('Input should be float or np.ndarray!')

    def __init__(self, trc: Union[str, 'TransferFunction'] = 'sRGB') -> None:
        # Copy construct
        if isinstance(trc, TransferFunction):
            self.name = trc.name
            self.__trc = trc.__trc
            self.__inv_trc = trc.__inv_trc

        # Construct from a string
        elif isinstance(trc, str):
            if not trc.lower() in COLORSPACE_CANONICAL_NAME_MAP:
                raise ValueError(f'Transfer function name {trc} cannot recognize!')

            self.name = COLORSPACE_CANONICAL_NAME_MAP[trc.lower()]
            # Do nothing for linear transfer funtion
            if self.name == 'Linear':
                self.__trc = lambda x: x
                self.__inv_trc = lambda x: x
                return

            elif self.name == 'sRGB' or self.name == 'DisplayP3':
                a, b, g, k = 0.055, 0.0031308, 2.4, 12.92
            elif self.name == 'DCIP3':
                a, b, g, k = 0, 0, 2.6, 0
            elif self.name == 'AdobeRGB':
                a, b, g, k = 0.0, 0.0, 2.2, 0.0
            elif self.name == 'BT.709':
                a, b, g, k = 0.099, 0.018, 1.0 / 4.5, 4.5
            elif self.name == 'BT.2020':
                a, b, g, k = 0.099297, 0.018053, 1.0 / 4.5, 4.5
            else:
                raise ValueError(f'Cannot recognize transfer function name {self.name}')

            self.__trc = lambda x: TransferFunction.__gamma(x, g, a, b, k)
            self.__inv_trc = lambda x: TransferFunction.__inv_gamma(x, g, a, b, k)

        else:
            raise TypeError('wrong type for input argument trc!')

    def __call__(self, x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        return self.__trc(x)

    def __eq__(self, __o: object) -> bool:
        if not isinstance(__o, TransferFunction):
            return False
        return self.name == __o.name

    def foward(self, x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        return self.__trc(x)

    def inverse(self, x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        return self.__inv_trc(x)


class RgbSpace(object):
    """
    RGB colorspace.

    Properties:
    - name: The name of the colorspace, such as sRGB, AdobeRGB, etc.
    - wp: The white point of the colorspace, represented by a WhitePoint object.
    - pri: The xyz coordinates of the primaries, with the constraint x + y + z = 1.
    - trc: The transfer characteristic function that converts linear signal to non-linear.

    Note:
    - The name of the colorspace must be one of the supported names: sRGB, AdobeRGB, BT.709, BT.2020, DisplayP3, DCIP3,
      and their aliases: 709, bt709, bt.709, 2020, bt2020, p3, p3d65, etc. See COLORSPACE_NAMES for details.
    - The xyz coordinates of the primaries must satisfy the constraint x + y + z = 1.

    Example:
    ```python
    # Create an instance of the RGB colorspace
    rgb_space = RgbSpace('sRGB')
    ```
    """

    @staticmethod
    def get_white_point(name: str) -> WhitePoint:
        if name in ['sRGB', 'AdobeRGB',
                    'BT.709', 'BT.2020', 'DisplayP3', ]:
            return WhitePoint('d65')
        elif name in ['DCIP3', ]:
            return WhitePoint('dci')
        else:
            raise ValueError(f'Cannot recognize white point name {name}')

    @staticmethod
    def get_primaries(name: str) -> np.ndarray:
        # rows for R, G, B
        # cols for x, y, z
        if name == 'sRGB':
            pri = np.array([[0.6400, 0.3300],
                            [0.3000, 0.6000],
                            [0.1500, 0.0600]])
        elif name == 'AdobeRGB':
            pri = np.array([[0.6400, 0.3300],
                            [0.2100, 0.7100],
                            [0.1500, 0.0600]])
        elif name == 'BT.709':
            pri = np.array([[0.708, 0.292],
                            [0.170, 0.797],
                            [0.131, 0.046]])
        elif name == 'BT.2020':
            pri = np.array([[0.708, 0.292],
                            [0.170, 0.797],
                            [0.131, 0.046]])
        elif name == 'DisplayP3' or name == 'DCIP3':
            pri = np.array([[0.680, 0.320],
                            [0.265, 0.690],
                            [0.150, 0.060]])
        else:
            raise ValueError(f'Primary name {name} cannot recognize!')

        return np.c_[pri, (1 - np.sum(pri, axis=1))]

    def __init__(self, cs: Union[str, 'RgbSpace'] = 'sRGB', linear_trc: bool = False) -> None:
        # Copy construct
        if isinstance(cs, RgbSpace):
            self.name = cs.name
            self.wp = WhitePoint(cs.wp)
            self.pri = cs.pri
            self.mat_rgb2xyz = cs.mat_rgb2xyz
            self.mat_xyz2rgb = cs.mat_xyz2rgb
            if linear_trc:
                self.trc = TransferFunction('linear')
            else:
                self.trc = TransferFunction(cs.trc)

        # Construct from a string
        elif isinstance(cs, str):
            if cs.lower() not in COLORSPACE_CANONICAL_NAME_MAP:
                raise ValueError(f'Colorspace name {cs} cannot recognize!')

            self.name = COLORSPACE_CANONICAL_NAME_MAP[cs.lower()]
            self.wp = RgbSpace.get_white_point(self.name)
            self.pri = RgbSpace.get_primaries(self.name)
            if linear_trc:
                self.trc = TransferFunction('linear')
            else:
                self.trc = TransferFunction(self.name)
            inv_pri = np.linalg.inv(self.pri)
            dw = self.wp.xyz @ inv_pri
            self.mat_rgb2xyz = np.diag(dw) @ self.pri
            self.mat_xyz2rgb = np.linalg.inv(self.mat_rgb2xyz)

        else:
            raise TypeError(f'Wrong type for colorspace name {cs}!')

    def __eq__(self, __o: object) -> bool:
        if not isinstance(__o, RgbSpace):
            return False

        return self.name == __o.name and self.trc == __o.trc


class YCbCrSpace(object):
    """
    YCbCr colorspace.

    The YCbCr colorspace represents colors in terms of their luminance (Y) and chrominance (Cb and Cr) components.
    It is commonly used in video and image compression.

    Properties:
    - name: The name of the colorspace, such as BT.709, BT.2020, etc.
    - pri: The xyz coordinates of the primaries, represented by a list [x, y, z].
    - trc: The transfer function that converts linear signal to non-linear.
    - coef: The coefficients for conversion to RGB space, represented by a list [y1, y2, y3, cb, cr].

    Note:
    - The name of the colorspace must be one of the supported names: BT.709, BT.2020, DisplayP3, DCIP3,
      and their aliases: 709, bt709, bt.709, 2020, bt2020, p3, p3d65, etc. See COLORSPACE_NAMES for details.

    Example:
    ```python
    # Create an instance of the YCbCr colorspace
    ycbcr_space = YCbCrSpace('BT.709')
    ```
    """

    @staticmethod
    def __get_coef(name):
        if name == 'BT.709':
            y_coef = np.array([0.2126, 0.7152, 0.0722])
            cbcr_coef = np.array([1.8556, 1.5748])
        elif name == 'BT.2020' or name == 'DisplayP3' or name == 'DCIP3':
            y_coef = np.array([0.2627, 0.6780, 0.0593])
            cbcr_coef = np.array([1.8814, 1.4746])
        else:
            raise ValueError(f'YCbCr space name {name} cannot recognize!')

        return np.concatenate((y_coef, cbcr_coef))

    def __init__(self, cs: Union[str, 'YCbCrSpace'] = '709') -> None:
        # Copy construct
        if isinstance(cs, YCbCrSpace):
            self.name = cs.name
            self.pri = cs.pri
            self.trc = cs.trc
            self.coef = cs.coef

        # Construct from string
        elif isinstance(cs, str):
            if cs.lower() not in COLORSPACE_CANONICAL_NAME_MAP:
                raise ValueError(f'YCbCr colorspace name {cs} cannot recognize!')
            self.name = COLORSPACE_CANONICAL_NAME_MAP[cs.lower()]
            self.pri = RgbSpace.get_primaries(self.name)
            self.trc = TransferFunction(self.name)
            self.coef = self.__get_coef(self.name)

        else:
            raise TypeError('wrong type for argument cs!')

    def __eq__(self, __o: object) -> bool:
        if not isinstance(__o, YCbCrSpace):
            return False
        return self.name == __o.name and self.trc == __o.trc

    def get_associated_rgb(self) -> RgbSpace:
        return RgbSpace(self.name)


def rgb_to_xyz(x: np.ndarray, rgb: Union[str, RgbSpace] = 'sRGB') -> np.ndarray:
    # Check input image
    if not common.check_color_chn(x, 3):
        raise common.DimensionNotMatchError('Input data should be 3-channel!')

    rgb = RgbSpace(rgb)

    # Convert to linear RGB
    if rgb.name != 'Linear':
        x = rgb.trc.inverse(x)

    # Convert to XYZ
    old_shape = x.shape
    x = x.reshape((-1, 3)) @ rgb.mat_rgb2xyz
    x = x.reshape(old_shape)

    return x


def xyz_to_rgb(x: np.ndarray, rgb: Union[str, RgbSpace] = 'sRGB') -> np.ndarray:
    # Check input image
    if not common.check_color_chn(x, 3):
        raise common.DimensionNotMatchError('Input data should be 3-channel!')

    rgb = RgbSpace(rgb)

    # Convert to linear RGB
    old_shape = x.shape
    x = x.reshape((-1, 3)) @ rgb.mat_xyz2rgb
    x = x.reshape(old_shape)

    # Convert to non-linear RGB (gamma)
    if rgb.name != 'Linear':
        x = rgb.trc(x)

    return x


def rgb_to_rgb(x: np.ndarray, rgb_from: Union[str, RgbSpace] = 'sRGB', rgb_to: Union[str, RgbSpace] = 'sRGB') -> np.ndarray:
    rgb_from = RgbSpace(rgb_from)
    rgb_to = RgbSpace(rgb_to)

    # Do nothing if the two colorspaces are the same
    if rgb_from == rgb_to:
        return x.copy()

    # Convert to XYZ
    x = rgb_to_xyz(x, rgb_from)

    # Convert to RGB
    x = xyz_to_rgb(x, rgb_to)

    return x


def rgb_to_ycbcr(x: np.ndarray, rgb: Union[str, RgbSpace] = 'sRGB', ycbcr: Union[str, YCbCrSpace] = '709') -> np.ndarray:
    rgb = RgbSpace(rgb)
    ycbcr = YCbCrSpace(ycbcr)

    coef_y = ycbcr.coef[0:3]
    coef_cb = ycbcr.coef[3]
    coef_cr = ycbcr.coef[4]

    # Convert to destination RGB space that is associated with the destination YCbCr space
    x = rgb_to_rgb(x, rgb, ycbcr.get_associated_rgb())

    m = np.concatenate((coef_y,
                        (np.array([0, 0, 1.0]) - coef_y) / coef_cb,
                        (np.array([1.0, 0, 0]) - coef_y) / coef_cr), axis=1).transpose()

    old_shape = x.shape
    x = x.reshape((-1, 3)) @ m
    x = x.reshape(old_shape)

    return x
