library(readr)
library(ggplot2)

genes <- read_tsv("GENES_TFBS_reldist.tsv")
genes$catagory <- rep("Gene", times = length(genes[,1]))
TSS <- read_tsv("TSS_TFBS_reldist.tsv")
TSS$catagory <- rep("TSS", times = length(genes[,1]))
data <- rbind(genes, TSS)

ggplot(data, aes(reldist, fraction, color = catagory)) + 
    geom_point() + geom_line() +
    labs(list(title = "Relative distance between trascription factor binding sites 
              and genes or transctiption start sites",
         x = "Relative Distance", y = "Frequency", color = "")) +
    theme(legend.title=element_blank()) +
    scale_color_tableau()

ggsave("reldist.png")

