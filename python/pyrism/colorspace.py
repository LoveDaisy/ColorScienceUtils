import numpy as np
from typing import Union, Optional

from . import common
from . import gamutmatch

"""
This module defines various colorspaces used in color science, including RGB, YCbCr, CMYK, Lab, XYZ, etc.
Colorspaces can be categorized as absolute and universal, such as XYZ, or relative and defined by 'anchors' in absolute spaces, such as RGB.
Some colorspaces are smaller than others, for example, sRGB is smaller than AdobeRGB.
Certain colorspaces are closely associated with each other, like YCbCr and RGB, where each YCbCr space is tied to an associated RGB space.

Note: This module is part of the `pyrism` package for color science.
"""


COLORSPACE_NAMES = {
    'sRGB': {
        'short': 'sRGB',
        'alias': ['srgb', ],
    },
    'AdobeRGB': {
        'short': 'ARGB',
        'alias': ['argb', 'adobergb', ],
    },
    'BT.601': {
        'short': '470bg',
        'alias': ['601', 'bt601', 'bt.601', '601-625', 'bt601-625', 'bt.601-625', 'bt470bt', '470bg', ],
    },
    'BT.601-525': {
        'short': 'smpte170m',
        'alias': ['601-525', 'bt601-525', 'bt.601-525', 'smpte170m', '170m', ],
    },
    'BT.709': {
        'short': '709',
        'alias': ['709', 'bt709', 'bt.709', ],
    },
    'BT.2020NCL': {
        'short': '2020NCL',
        'alias': ['2020', 'bt2020', 'bt.2020', '2020ncl', 'bt2020ncl', 'bt.2020ncl', ],
    },
    'DisplayP3': {
        'short': 'P3D65',
        'alias': ['p3', 'p3d65', 'd65p3', 'displayp3', ],
    },
    'DCIP3': {
        'short': 'P3DCI',
        'alias': ['p3dci', 'dcip3', ],
    },
}

COLORSPACE_CANONICAL_NAME_MAP = {a: n for n, v in COLORSPACE_NAMES.items() for a in v['alias']}


def xy_to_xyz(xy: np.ndarray, Y: Optional[float] = None) -> np.ndarray:
    if len(xy.shape) == 1:
        xyz = np.array([xy[0], xy[1], 1 - xy[0] - xy[1]])
        if Y is not None:
            xyz = xyz * Y / xy[1]
    elif len(xy.shape) == 2:
        xyz = np.c_[xy, (1 - np.sum(xy, axis=1))]
        if Y is not None:
            xyz = xyz * Y / xyz[:, 1]
    else:
        raise ValueError('Input xy should be 1D or 2D array!')
    return xyz


WHITE_POINT_PARAM = {
    'D65': xy_to_xyz(np.array([0.3127, 0.3290]), Y=1.0),
    'D60': xy_to_xyz(np.array([0.32168, 0.33767]), Y=1.0),
    'DCI': xy_to_xyz(np.array([0.314, 0.351]), Y=1.0),
    'E': xy_to_xyz(np.array([1/3, 1/3]), Y=1.0),
}


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
            if self.name in WHITE_POINT_PARAM:
                self.xyz = WHITE_POINT_PARAM[self.name]
            else:
                raise ValueError(f'white point name {wp} cannot recognize!')
        else:
            raise TypeError('wrong type for input argument wp!')

    def __eq__(self, __o: object) -> bool:
        if not (__o, WhitePoint):
            return False
        return self.name == __o.name


TRC_PARAM = {
    'sRGB': (0.055, 0.0031308, 2.4, 12.92),
    'AdobeRGB': (0.0, 0.0, 2.2, 0.0),
    'BT.601': (0.099, 0.018, 1.0 / 0.45, 4.5),
    'BT.601-525': (0.099, 0.018, 1.0 / 0.45, 4.5),
    'BT.709': (0.099, 0.018, 1.0 / 0.45, 4.5),
    'BT.2020NCL': (0.099297, 0.018053, 1.0 / 0.45, 4.5),
    'DisplayP3': (0.055, 0.0031308, 2.4, 12.92),
    'DCIP3': (0.0, 0.0, 2.6, 0.0),
}


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
        if abs(x) < b:
            return x * k
        else:
            return x / abs(x) * ((abs(x) + a) / (1 + a)) ** g

    @staticmethod
    def __array_gamma(x: np.ndarray, g: float, a: float, b: float, k: float) -> np.ndarray:
        idx0 = x < b
        idx1 = np.logical_not(idx0)
        y = np.zeros_like(x)
        y[idx0] = x[idx0] * k
        y[idx1] = np.sign(x[idx1]) * (np.abs(x[idx1]) ** g * (1 + a) - a)
        return y

    @staticmethod
    def __array_inv_gamma(x: np.ndarray, g: float, a: float, b: float, k: float) -> np.ndarray:
        idx0 = x < b
        idx1 = np.logical_not(idx0)
        y = np.zeros_like(x)
        y[idx0] = x[idx0] * k
        y[idx1] = np.sign(x[idx1]) * ((np.abs(x[idx1]) + a) / (1 + a)) ** g
        return y

    @staticmethod
    def __gamma(x: Union[float, np.ndarray], g: float, a: float,
                b: Optional[float] = None, k: Optional[float] = None) -> Union[float, np.ndarray]:
        g = 1 / g
        if b is None:
            b = ((1 + a) * (1 - g) / a) ** (-1 / g)
        if k is None:
            k = (1 + a) * b ** (g - 1)

        if isinstance(x, float):
            return TransferFunction.__single_gamma(x, g, a, b, k)
        elif isinstance(x, np.ndarray):
            return TransferFunction.__array_gamma(x, g, a, b, k)
        else:
            raise TypeError('Input should be float or np.ndarray!')

    @staticmethod
    def __inv_gamma(x: Union[float, np.ndarray], g: float, a: float,
                    b: Optional[float] = None, k: Optional[float] = None) -> Union[float, np.ndarray]:
        if b is not None and k is not None:
            b = b * k
        else:
            b = a / (g - 1)
        if k is None:
            k = (b * g / (1 + a)) ** g * (g - 1) / a
        elif abs(k) < 1e-8:
            k = float('inf')
        else:
            k = 1 / k

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
            self.name = COLORSPACE_CANONICAL_NAME_MAP[trc.lower()]
            if self.name not in TRC_PARAM:
                raise ValueError(f'Transfer function name {trc} cannot recognize!')

            # Do nothing for linear transfer funtion
            if self.name == 'Linear':
                self.__trc = lambda x: x
                self.__inv_trc = lambda x: x
                return
            else:
                a, b, g, k = TRC_PARAM[self.name]

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


COLORSPACE_PARAM = {
    'sRGB': {
        'white_point': WhitePoint('D65'),
        'primaries': xy_to_xyz(
            np.array([[0.6400, 0.3300],
                      [0.3000, 0.6000],
                      [0.1500, 0.0600]])),
        'transfer_function': TransferFunction('sRGB'),
    },
    'AdobeRGB': {
        'white_point': WhitePoint('D65'),
        'primaries':  xy_to_xyz(
            np.array([[0.6400, 0.3300],
                      [0.2100, 0.7100],
                      [0.1500, 0.0600]])),
        'transfer_function': TransferFunction('AdobeRGB'),
    },
    'BT.601': {
        'white_point': WhitePoint('D65'),
        'primaries':  xy_to_xyz(
            np.array([[0.64, 0.33],
                      [0.29, 0.60],
                      [0.15, 0.06]])),
        'transfer_function': TransferFunction('BT.601'),
        'y_coef': np.array([0.299, 0.587, 0.114]),
        'cbcr_coef': [1.772, 1.402],
    },
    'BT.601-525': {
        'white_point': WhitePoint('D65'),
        'primaries': xy_to_xyz(
            np.array([[0.630, 0.340],
                      [0.310, 0.595],
                      [0.155, 0.070]])),
        'transfer_function': TransferFunction('BT.601-525'),
        'y_coef': np.array([0.299, 0.587, 0.114]),
        'cbcr_coef': [1.772, 1.402],
    },
    'BT.709': {
        'white_point': WhitePoint('D65'),
        'primaries': xy_to_xyz(
            np.array([[0.640, 0.330],
                      [0.300, 0.600],
                      [0.150, 0.060]])),
        'transfer_function': TransferFunction('BT.709'),
        'y_coef': np.array([0.2126, 0.7152, 0.0722]),
        'cbcr_coef': [1.8556, 1.5748],
    },
    'BT.2020NCL': {
        'white_point': WhitePoint('D65'),
        'primaries': xy_to_xyz(
            np.array([[0.708, 0.292],
                      [0.170, 0.797],
                      [0.131, 0.046]])),
        'transfer_function': TransferFunction('BT.2020NCL'),
        'y_coef': np.array([0.2627, 0.6780, 0.0593]),
        'cbcr_coef': [1.8814, 1.4746],
    },
    'DisplayP3': {
        'white_point': WhitePoint('D65'),
        'primaries': xy_to_xyz(
            np.array([[0.680, 0.320],
                      [0.265, 0.690],
                      [0.150, 0.060]])),
        'transfer_function': TransferFunction('DisplayP3'),
        'y_coef': np.array([0.2627, 0.6780, 0.0593]),
        'cbcr_coef': [1.8814, 1.4746],
    },
    'DCIP3': {
        'white_point': WhitePoint('DCI'),
        'primaries': xy_to_xyz(
            np.array([[0.680, 0.320],
                      [0.265, 0.690],
                      [0.150, 0.060]])),
        'transfer_function': TransferFunction('DCIP3'),
        'y_coef': np.array([0.2627, 0.6780, 0.0593]),
        'cbcr_coef': [1.8814, 1.4746],
    },
}


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
            self.wp = COLORSPACE_PARAM[self.name]['white_point']
            self.pri = COLORSPACE_PARAM[self.name]['primaries']
            if linear_trc:
                self.trc = TransferFunction('linear')
            else:
                self.trc = COLORSPACE_PARAM[self.name]['transfer_function']
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
            self.pri = COLORSPACE_PARAM[self.name]['primaries']
            self.trc = TransferFunction(self.name)

            coef_y = COLORSPACE_PARAM[self.name]['y_coef']
            coef_cbcr = COLORSPACE_PARAM[self.name]['cbcr_coef']
            self.mat_rgb2ycbcr = np.vstack((coef_y,
                                            (np.array([0, 0, 1.0]) - coef_y) / coef_cbcr[0],
                                            (np.array([1.0, 0, 0]) - coef_y) / coef_cbcr[1])).transpose()

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

    if isinstance(rgb, str):
        rgb = RgbSpace(rgb)

    # Convert to linear RGB
    if rgb.name != 'Linear':
        x = rgb.trc.inverse(x)

    # Convert to XYZ
    old_shape = x.shape
    x = x.reshape((-1, 3)) @ rgb.mat_rgb2xyz
    x = x.reshape(old_shape)

    return x


def xyz_to_rgb(x: np.ndarray, rgb: Union[str, RgbSpace] = 'sRGB', clip_method: Optional[str] = None) -> np.ndarray:
    # Check input image
    if not common.check_color_chn(x, 3):
        raise common.DimensionNotMatchError('Input data should be 3-channel!')
    # Check clip method
    if clip_method is not None and clip_method.lower() not in ['clip', 'none',]:
        raise ValueError('Invalid clip method!')

    if isinstance(rgb, str):
        rgb = RgbSpace(rgb)

    # Convert to linear RGB
    old_shape = x.shape
    x = x.reshape((-1, 3)) @ rgb.mat_xyz2rgb
    x = x.reshape(old_shape)

    if clip_method is not None and clip_method.lower() == 'clip':
        x = gamutmatch.clip(x)

    # Convert to non-linear RGB (gamma)
    if rgb.name != 'Linear':
        x = rgb.trc(x)

    return x


def rgb_to_rgb(x: np.ndarray, rgb_from: Union[str, RgbSpace] = 'sRGB', rgb_to: Union[str, RgbSpace] = 'sRGB',
               clip_method: Optional[str] = None) -> np.ndarray:
    # Check input image
    if not common.check_color_chn(x, 3):
        raise common.DimensionNotMatchError('Input data should be 3-channel!')

    if isinstance(rgb_from, str):
        rgb_from = RgbSpace(rgb_from)
    if isinstance(rgb_to, str):
        rgb_to = RgbSpace(rgb_to)

    # Do nothing if the two colorspaces are the same
    if rgb_from == rgb_to:
        return x.copy()

    # Convert to XYZ
    x = rgb_to_xyz(x, rgb_from)

    # Convert to RGB
    x = xyz_to_rgb(x, rgb_to, clip_method=clip_method)

    return x


def rgb_to_ycbcr(x: np.ndarray, rgb: Union[str, RgbSpace] = 'sRGB', ycbcr: Union[str, YCbCrSpace] = '709',
                 clip_method: Optional[str] = None) -> np.ndarray:
    # Check input image
    if not common.check_color_chn(x, 3):
        raise common.DimensionNotMatchError('Input data should be 3-channel!')

    if isinstance(ycbcr, str):
        ycbcr = YCbCrSpace(ycbcr)
    rgb2 = ycbcr.get_associated_rgb()

    # Convert to destination RGB space that is associated with the destination YCbCr space
    x = rgb_to_rgb(x, rgb_from=rgb, rgb_to=rgb2, clip_method=clip_method)

    old_shape = x.shape
    x = x.reshape((-1, 3)) @ ycbcr.mat_rgb2ycbcr
    x = x.reshape(old_shape)

    return x
