
## Intro to SAM/BAM format
SAM (Sequence Alignment/Map) format is one of the most common file formats produced by many different pieces of alignment software, both for long and short read sequence data. It is a tab delineated text file, with 11 mandatory fields (listed below), plus header lines denoted with an `@` at the start of the line.

SAM files are human readable, but can be quite large. An alternate format is the Binary Alignment/Map (BAM) file, which is binary compressed and not human readable, but is more compact and easy to work with. Most pipelines will use BAM format over SAM.

### General pipeline
Map reads (BWA, Bowtie, minimap, etc.) --> Filter --> Sort --> Index  
*Filter*:

## SAMtools
SAMtools is a suite of programs that are extremely useful for processing mapped reads and for downstream analysis. It has a ton of functions (which you can check out on the manual page), but we will go through several of the most common uses.

One of the most useful tools for the first processing of mapped reads is `samtools view`, which allows you to view the contents of a BAM/SAM file in SAM format.

### Viewing specific regions
By default `samtools view` prints all alignments, but you can specify a specific chromosome or subregion to only print alignments in that window:

`samtools view file.bam chr1 | head`  
`samtools view file.bam chr1:1000-2000 | head`

### Converting between formats

### SAM flags

## Downstream analysis

### Calculating coverage
One of the most common things you will want to know about your mapped reads is their coverage and depth, as this can impact your confidence in the assembly, the validity of your SNP calls, etc. There are many approaches you can take to calculate depth, several of which you can do with SAMtools.    

`samtools coverage`: for each contig/scaffold in the BAM/SAM file, outputs several useful summary stats as a table:
`samtools coverage file.sorted.bam`

Like with `samtools view`, can also specify coordinates:

`samtools coverage file.sorted.bam -r 1`

As a quick way to visualize coverage, you can use the `-m` option create a histogram of coverage over a contig:

`samtools coverage ERR1013163.sorted.bam -r 1`
### Stats/flagstats

## Other tricks

### Adding headers back

### BAM to FASTQ/A

### Merge BAM files

## Exercises?
