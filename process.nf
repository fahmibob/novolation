process bwaMem {
    input:
    tuple val(sampleName), path(forward), path(reverse)
    path(reference)

    output:
    
    script:
    """
    bwa index $reference
    
    bwa mem -t 2\
    -K 100000000 \
    $reference \
    $forward \
    $reverse | samtools view -Sb > $sampleName'.bam'
    """
}

process cdhit {
    input:
    output:
    script:
    """
    
    """
}