import numpy as np

def energy_det(sigIn, nAnt, approach):
    """
    Compute an energy detection decision over multiple antennas.

    Parameters:
        sigIn    : 2D numpy array of shape (nn, nSamp), complex or real.
                   Each row corresponds to one antenna, each column to one sample.
        nAnt     : Number of antennas to include in the energy calculation (int).
        approach : An object with attributes:
                   - type        : descriptor for this detection approach.
                   - detail.thresh : energy threshold (float).

    Returns:
        det : dict with keys:
              - 'type'     : copied from approach.type.
              - 'decision' : bool, True if detected energy > threshold.
              - 'vals'     : computed average energy per antenna per sample.
    """
    det = {}
    # Preserve the detector type from the approach specification
    det['type'] = approach.type

    # sigIn is assumed to have shape (nn, nSamp)
    nn, nSamp = sigIn.shape

    # Default decision is False
    det['decision'] = False

    # Sum energy across the first nAnt antennas and all samples
    # Equivalent to sum(sum(sigIn[0:nAnt, :] * conj(sigIn[0:nAnt, :])))
    energy_sum = np.sum(sigIn[0:nAnt, :] * np.conj(sigIn[0:nAnt, :]))

    # Compute average energy per antenna per sample
    vals = energy_sum / nAnt / nSamp

    # Make a decision if the normalized energy exceeds the threshold
    if vals > approach.detail.thresh:
        det['decision'] = True

    # Store the computed energy value
    det['vals'] = vals

    return det
