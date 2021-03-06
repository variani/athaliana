# @ http://potatobreeding.cals.wisc.edu/wp-content/uploads/sites/21/2014/01/GWAS_tutorial.pdf

### read genotype markers
#markers <- read.csv("call_method_32.b",skip=1,header=T,as.is=T,check.names=FALSE)
markers <- read.csv(athaliana_file_snp(),skip=1,header=T,as.is=T,check.names=FALSE)

convert.snp <- function(x) 
{
  #convert to {1,0,1,NA}
  alleles <- na.omit(unique(x))
  
  y <- rep(NA,length(x))
  
  y[which(x==alleles[1])] <- -1
  y[which(x==alleles[2])] <- 1

  return(y)
}

### prepare matrix of genotype data for estimation of rel. matrix
M <- apply(markers[, -(1:2)],1,convert.snp)

#dim(M)
#[1]    199 216130

gid <- colnames(markers)[-(1:2)]
rownames(M) <- gid
n <- nrow(M)  # number of lines
m <- ncol(M)  # number of markers

### compute rel. mat
library(rrBLUP)
A <- A.mat(M)

#dim(A)
#[1] 199 199

### eigen of `A`
eig.result <- eigen(A)
lambda <- eig.result$values

plot(lambda/sum(lambda),ylab="Fraction Explained")

### prepare genotype data for GWAS
geno <- cbind(1:m,markers[,1:2],t(M))
colnames(geno) <- c("marker","chrom","pos",gid)

### read phen. data
#pheno <- read.table("phenotype_published_raw.tsv",header=T,as.is=T,check.names=FALSE,sep="\t")
pheno <- read.table(athaliana_file_phen(),header=T,as.is=T,check.names=FALSE,sep="\t")

#pheno2 <- pheno[,c(1,3,10,35,43)]
#colnames(pheno2) <- c("ecoid","FT_LD","Dormancy","avrRpm","FRI")

pheno2 <- pheno[,c(1,43)]
colnames(pheno2) <- c("ecoid","FRI")

### run GWAS
emmax <- GWAS(pheno=pheno2,geno=geno,P3D=TRUE,n.core=60,K=A)

mm <- GWAS(pheno=pheno2,geno=geno,P3D=FALSE,n.core=60,K=A)
