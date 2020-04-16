install.packages("BiocManager")

# packages required to knit HTML documents
install.packages(c("highr", "knitr", "markdown", "rmarkdown", "stringr", "yaml"))

# 2020-04-21 Differential Expression Analysis with Limma Voom
BiocManager::install(c("edgeR", "statmod"))
