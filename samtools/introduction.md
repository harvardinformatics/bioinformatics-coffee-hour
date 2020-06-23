
## Intro to SAM/BAM format
SAM (Sequence Alignment/Map) format is one of the most common file formats produced by many different pieces of alignment software, both for long and short read sequence data. It is a tab delineated text file, with 11 mandatory fields (listed below), plus header lines denoted with an `@` at the start of the line.

SAM files are human readable, but can be quite large. An alternate format is the Binary Alignment/Map (BAM) file, which is binary compressed and not human readable, but is more compact and easy to work with. Most pipelines will use BAM format over SAM.


## SAMtools
[SAMtools](http://www.htslib.org/doc/samtools.html) is a suite of programs that are extremely useful for processing mapped reads and for downstream analysis. It has a ton of functions (which you can check out on the manual page), but we will go through several of the most common uses.

### General pipeline
Once you've obtained your mapped reads in BAM/SAM format (from BWA, bowtie, minimap, etc.), there are several steps needed before starting downstream analysis.

*Filter*: generally this means removing unmapped reads from your file, which we will discuss below.

*Sort*: sort the mapped reads by contig/scaffold and by coordinates. This can be done using `samtools sort`:

`samtools sort -o file.sorted.bam file.bam`

*Index*: creates a searchable index of your sorted BAM file, which is required for some programs.

`samtools index file.sorted.bam`
 ___
One of the most useful tools for the first processing of mapped reads is `samtools view`, which allows you to view the contents of a BAM/SAM file in SAM format:

`samtools view file.bam | head`

| **Column**|  **Description** |
|-----|---|
|   1  | Read name  |
|   2  | Bitwise flag  |
|   3  |  Reference name |
|   4  |  Leftmost mapping position |
|   5  |  MAPQ quality score |
|   6  |  CIGAR string  |
|   7  |  Name of 2nd read in pair |
|   8  |  Position of 2nd read in pair |
|   9  |  Length of mapping segment |
|   10  |  Sequence of segment  |
|   11  |  Phred33 quality score at each position  |


### Viewing specific regions
By default `samtools view` prints all alignments, but you can specify a specific chromosome or subregion to only print alignments in that window:

`samtools view file.bam 1 | head`  
`samtools view file.bam 1:1-1000 | head`

If you have numerous regions of interest, you can format them as a BED file and pass that to `samtools view`. This can be slow with large BAM files, as it does not does not use the index.

`samtools view -h -o file.subset.bam -L subset.bed file.bam`

The `-o` option specifies an output file, rather than printing to screen. The `-h` option is important to remember, as it adds a header to the output. This is important, as many programs require a header to parse BAM/SAM files!

### Converting between formats
By default `samtools view` outputs in SAM format, so converting from BAM --> SAM is as easy as running `samtools view -h -o outfile.sam file.bam`.

For SAM --> BAM, include the `-b` option:

`samtools view -b -h -o outfile.bam file.sam`

### SAM flags
The second column in a BAM/SAM file is the *bitwise flag*. The flag value is an integer, which is the sum of a series of decimal values that give information about how a read is mapped

| **Integer**|  **Description** |
|-----|---|
|   1  | read is paired  |
|   2  | read mapped in proper pair  |
|   4  |  read unmapped |
|   8  |  mate is unmapped |
|   16  |  read on reverse strand |
|   32  |  mate on reverse strand  |
|   64  |  first read in pair |
|   128  |  second read in pair |
|   256  |  not primary alignment |
|   512  |  alignment fails quality checks  |
|   1024  |  PCR or optical duplicate  |
|   2048  |  supplementary alignment |

So e.g., for a paired-end mapping data set, a flag = **99** (1+2+32+64) means the read is mapped along with its mate (1 and 2) and in the proper orientation (32 and 64).

### Filtering reads
Probably the most important flag to remember is **4**, which means the read is **unmapped**. Unmapped reads are most often filtered out. You can filter reads containing a given flag using the `-f` (only take reads that match given flags) and `-F` (only take reads that do **NOT** match given flag) options in `samtools view`.

So to remove unmapped reads, you would run:

`samtools view -F 4 -h file.sorted.bam | head`

This removes any read that contains the 4 flag (e.g. 77, 141, etc.). You can filter on any other criteria using flags as well, e.g. only gets reads that map in proper pair:

`samtools view -f 2 -h file.sorted.bam`

(Note this uses `-f`, not `-F`!)

## Downstream analysis

### Calculating coverage
One of the most common things you will want to know about your mapped reads is their coverage and depth, as this can impact your confidence in the assembly, the validity of your SNP calls, etc. There are many approaches you can take to calculate depth, several of which you can do with SAMtools.    

`samtools coverage`: for each contig/scaffold in the BAM/SAM file, outputs several useful summary stats as a table:
`samtools coverage file.sorted.bam`

Like with `samtools view`, can also specify coordinates:

`samtools coverage file.sorted.bam -r 1`

As a quick way to visualize coverage, you can use the `-m` option create a histogram of coverage over a contig:

`samtools coverage -m ERR1013163.sorted.bam -r 1:1-1000`

You might also want to look at per-base coverage rather than the average. For this you can use `samtools depth`:

`samtools depth -a file.sorted.bam -r 1:1-1000 | head`

This outputs a three column list, where the 1st column is the contig name, the 2nd is the position, and the 3rd is the depth over that base. This list is convenient for importing to programs like R, where you can plot e.g. a histogram showing the distribution of per-base depth, or distribution of depth over a contig.

### Stats/flagstats
Another useful function built into SAMtools is `samtools stats`, which gives some quick summary statistics about your mapping reads. The amount of information it generates is somewhat overkill in most cases, so we will just look at the summary:

`samtools stats ERR1013163.sorted.subset.bam | grep ^SN | cut -f 2-`
## Other tricks

### Adding headers back

### BAM to FASTQ/A
If you want to extract the sequence info from the reads you can use `samtools fastq` or `samtools fasta`:

`samtools fastq file.bam | head`

You can also output the pairs to different files.

### Merge BAM files
You can combine multiple sorted BAM/SAM files, which can be useful if you have done multiple rounds of mapping:

`samtools merge file.bam file2.bam ...`

Unless otherwise specified, the headers will also be merged.
