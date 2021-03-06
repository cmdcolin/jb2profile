library(ggplot2)
library(patchwork)
library(reshape2)

# df has raw values
df <- read.csv("fps_table_processed.csv", sep = "\t")
df$time_between_frames <- 1 / df$average_fps
df$coverage <- paste0(df$coverage, "x coverage")
df$coverage <- factor(df$coverage, levels = c("20x coverage", "200x coverage", "400x coverage", "600x coverage", "800x coverage", "1000x coverage"))
df2 <- read.csv("fps_table_processed2.csv", sep = "\t")
df4 <- read.csv("fps_table_processed3.csv", sep = "\t")
df4 <- melt(df4,id.vars=c('coverage','program','file_type','read_type','window'))


bam <- df[df$file_type == "bam", ]
bam_sr <- bam[bam$read_type == "shortread", ]
bam_lr <- bam[bam$read_type == "longread", ]
cram <- df[df$file_type == "cram", ]
cram_sr <- cram[cram$read_type == "shortread", ]
cram_lr <- cram[cram$read_type == "longread", ]



bam2 <- df2[df2$file_type == "bam", ]
bam_sr2 <- bam2[bam2$read_type == "shortread", ]
bam_lr2 <- bam2[bam2$read_type == "longread", ]
cram2 <- df2[df2$file_type == "cram", ]
cram_sr2 <- cram2[cram2$read_type == "shortread", ]
cram_lr2 <- cram2[cram2$read_type == "longread", ]





bam4 <- df4[df4$file_type == "bam", ]
bam_sr4 <- bam4[bam4$read_type == "shortread", ]
bam_lr4 <- bam4[bam4$read_type == "longread", ]
cram4 <- df4[df4$file_type == "cram", ]
cram_sr4 <- cram4[cram4$read_type == "shortread", ]
cram_lr4 <- cram4[cram4$read_type == "longread", ]





plot_scatterplot <- function(df, title) {
  ggplot(df, aes(x = program, y = time_between_frames)) +
    geom_jitter(aes(color = program), show.legend = T) +
    labs(y = "time between frames (s)") +
    facet_grid(~coverage) +
    theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    ggtitle(title)
}



plot_boxplot <- function(df, df2, title) {
  ggplot() +
    geom_jitter(data=df,aes(x=program,y=time_between_frames,color=program))+
    geom_boxplot(data = df2, aes(x = program, middle=expected_value,ymin = p05, ymax = p95, lower = p25,  upper = p75), fatten = NULL, stat = "identity", alpha = 0.5) +
    labs(y = "time between frames (s)") +
    facet_grid(~coverage) +
    theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    ggtitle(title)
}


plot_cumsums <- function(df, title) {
  df$csum <- ave(df$time_between_frames, df$program, df$coverage, FUN = cumsum)
  df$count <- ave(df$time_between_frames, df$program, df$coverage, FUN = seq_along)


  ggplot(df, aes(x = csum, y = count)) +
    geom_line(aes(color = program)) +
    labs(x = "time (s)", y = "frame #") +
    facet_grid(~coverage, scale = "free") +
    ggtitle(title)
}


plot_lm <- function(df, title) {
  ggplot(df, aes(x = coverage, y = expected_value, color = program)) +
    geom_point() +
    stat_smooth(method = "lm", aes(color = program, fill = program)) +
    geom_errorbar(aes(ymin = p05, ymax = p95), width = 40, position = position_dodge(width = 20)) +
    labs(y = "Response time (s)") +
    ggtitle(title)
}


plot_bare <- function(df, title) {
  ggplot(df, aes(x = coverage, y = expected_value, color = program)) +
    geom_point() +
    stat_smooth(method = "lm", aes(color = program, fill = program), lty = 3,se=F, formula=y~x-1) +
    geom_errorbar(aes(ymin = p05, ymax = p95), width = 40, position = position_dodge(width = 20)) +
    labs(y = "Response time (s)") +
    ggtitle(title)
}

plot_superbare <- function(df, title) {
  ggplot(df, aes(x = coverage, y = expected_value, color = program)) +
    geom_point() +
    stat_smooth(method = "lm", aes(color = program, fill = program), lty = 3, se = F, formula=y~x-1) +
    labs(y = "Mean response time (s)") +
    ggtitle(title)
}



plot_bar <- function(df, title) {
  ggplot(df, aes(x=coverage,y=value,color=program,group=variable)) +
    geom_line(aes(linetype=variable)) +
    facet_grid(~program) +
    ggtitle(title)
}





ggsave2<-function(file,plot,width,height) {
  ggsave(paste0(file,".png"),  plot, width = 16, height = 10)
  ggsave(paste0(file,".pdf"),  plot, width = 16, height = 10)
}





ggsave2("img/fps_scatter",
  (plot_scatterplot(cram_lr, "CRAM longread - main thread stall") /
    plot_scatterplot(cram_sr, "CRAM shortread - main thread stall") /
    plot_scatterplot(bam_lr, "BAM longread - main thread stall") /
    plot_scatterplot(bam_sr, "BAM shortread - main thread stall")),
  width = 16, height = 10
)

ggsave2("img/fps_cumsums",
  (plot_cumsums(cram_lr, "CRAM longread - frame # vs time") +
    plot_cumsums(cram_sr, "CRAM shortread - frame # vs time")) /
    (plot_cumsums(bam_lr, "BAM longread - frame # vs time") +
      plot_cumsums(bam_sr, "BAM shortread - frame # vs time")),
  width = 16
)




ggsave2("img/fps_ev",
  (plot_lm(cram_lr2, "CRAM longread - mean response time") +
    plot_lm(cram_sr2, "CRAM shortread - mean response time")) /
    (plot_lm(bam_lr2, "BAM longread - mean response time") +
      plot_lm(bam_sr2, "BAM shortread - mean response time")),
  width = 16
)



ggsave2("img/fps_bare",
  (plot_bare(cram_lr2, "CRAM longread - average response time") +
    plot_bare(cram_sr2, "CRAM shortread - average response time")) /
    (plot_bare(bam_lr2, "BAM longread - average response time") +
      plot_bare(bam_sr2, "BAM shortread - average response time")),
  width = 16
)



ggsave2("img/fps_superbare",
  (plot_superbare(cram_lr2, "CRAM longread - mean response time - viewing 10kb region") +
    plot_superbare(cram_sr2, "CRAM shortread - mean response time - viewing 10kb region")) /
    (plot_superbare(bam_lr2, "BAM longread - mean response time - viewing 10kb region") +
      plot_superbare(bam_sr2, "BAM shortread - mean response time - viewing 10kb region")),
  width = 16
)

ggsave2("img/fps_bar",
  (plot_bar(cram_lr4, "CRAM longread - time spent hanging") +
    plot_bar(cram_sr4, "CRAM shortread - time spent hanging")) /
    (plot_bar(bam_lr4, "BAM longread - time spent hanging") +
      plot_bar(bam_sr4, "BAM shortread - time spent hanging")),
  width = 16
)



df3 <- df2
df3$coverage <- paste0(df3$coverage, "x coverage")
df3$coverage <- factor(df3$coverage, levels = c("20x coverage", "200x coverage", "400x coverage", "600x coverage", "800x coverage", "1000x coverage"))

bam3 <- df3[df3$file_type == "bam", ]
bam_sr3 <- bam3[bam3$read_type == "shortread", ]
bam_lr3 <- bam3[bam3$read_type == "longread", ]
cram3 <- df3[df3$file_type == "cram", ]
cram_sr3 <- cram3[cram3$read_type == "shortread", ]
cram_lr3 <- cram3[cram3$read_type == "longread", ]



ggsave2("img/fps_scatter_boxplot", (plot_boxplot(cram_lr, cram_lr3, "CRAM longread - main thread stall - viewing 10kb region") /
    plot_boxplot(cram_sr, cram_sr3, "CRAM shortread - main thread stall - viewing 10kb region") /
    plot_boxplot(bam_lr, bam_lr3, "BAM longread - main thread stall - viewing 10kb region") /
    plot_boxplot(bam_sr, bam_sr3, "BAM shortread - main thread stall - viewing 10kb region")), width = 16, height = 10)
