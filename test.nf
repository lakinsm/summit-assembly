#!/usr/bin/env nextflow

process QualityControl {
    """
    #!/usr/bin/env bash
    cd /projects/$USER/meg-assembly/project4
    echo "Quality Control Test"
    echo "$PWD"
    """
}

process AssembleReads {
    """
    #!/usr/bin/env bash
    cd /projects/$USER/meg-assembly/project4
    echo "Assemble Reads Test"
    echo "$PWD"
    """
}
