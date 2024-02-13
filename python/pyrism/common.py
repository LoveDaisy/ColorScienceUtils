import numpy as np


def check_img_dim(x: np.ndarray, num_ch: int = -1) -> bool:
    """
    Check if the input image has the correct number of dimensions and channels.

    Parameters:
        x (np.ndarray): The input image.
        num_ch (int): The expected number of channels. Default is -1, which means any number is OK.

    Returns:
        bool: True if the image has the correct dimensions and channels, False otherwise.
    """
    if x.ndim not in [2, 3]:
        return False

    if x.ndim == 3 and num_ch > 0 and x.shape[2] != num_ch:
        return False

    return True


def check_color_chn(x: np.ndarray, num_ch: int = 3) -> bool:
    """
    Check if the input image has the correct number of color channels.

    Parameters:
        x (np.ndarray): The input image.
        num_ch (int): The expected number of channels. Default is 3.

    Returns:
        bool: True if the image has the correct number of color channels, False otherwise.
    """
    if x.shape[-1] != num_ch:
        return False

    return True
