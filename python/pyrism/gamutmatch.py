import numpy as np


def clip(x: np.ndarray, min_val: float = 0.0, max_val: float = 1.0) -> np.ndarray:
    """
    Clip the input array to the specified range.

    Parameters:
        x (np.ndarray): The input array.
        min_val (float): The minimum value. Default is 0.0.
        max_val (float): The maximum value. Default is 1.0.

    Returns:
        np.ndarray: The clipped array.
    """
    return np.clip(x, min_val, max_val)
