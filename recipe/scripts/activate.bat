:: Store existing env vars so we can restore them later
@if defined ECCODES_DEFINITION_PATH (
    set "_CONDA_SET_ECCODES_DEFINITION_PATH=%ECCODES_DEFINITION_PATH%
)
@if defined ECCODES_SAMPLES_PATH (
    set "_CONDA_SET_ECCODES_SAMPLES_PATH=%ECCODES_SAMPLES_PATH%
)

@set "ECCODES_DEFINITION_PATH=%CONDA_PREFIX%\Library\share\eccodes\definitions"
@set "ECCODES_SAMPLES_PATH=%CONDA_PREFIX%\Library\share\eccodes\samples"
