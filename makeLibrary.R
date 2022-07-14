cs.dir <- "~/../Dropbox/MERA_Case_Studies/Case study files"
cs.dir <- "~/../Users/Adrian/Dropbox/MERA_Case_Studies/Case study files"

mera.dirs <- list.dirs(cs.dir, recursive = FALSE)

# Delete existing library files
fls <- list.files("content/MERA_library")
if(length(fls)>0) {
  unlink("content/MERA_library/*", recursive = TRUE)
}

missing <- NULL
i <- 0 
count <- 0 
DFlist <- list()
for (dir in mera.dirs) {
  count <- count + 1
  message(count, '/', length(mera.dirs))
  if (file.exists(file.path(dir, 'MERA_1.mera'))) {
    i <- i + 1
    MERAfile <- readRDS(file.path(dir, 'MERA_1.mera'))
    dir.create(file.path("content/MERA_library", basename(dir)))
    
    file.copy(file.path(dir, 'MERA_1.mera'), 
              file.path('content/MERA_library', basename(dir), paste0(basename(dir),'.mera')))
    
    files <- list.files(dir)
    Report <- files[grepl(".html", files)]
    if (length(Report)>1) {
      Report <- Report[grepl("Questionnaire", Report)]
    }
    hasRep <- FALSE
    if (length(Report)==1) {
      file.copy(file.path(dir, Report), 
                file.path('content/MERA_library', basename(dir), paste0(basename(dir),'.html')))
      hasRep <- TRUE
    }
    
    
    DFlist[[i]] <- data.frame(Name=MERAfile[[3]]$Name,
                              Species=MERAfile[[3]]$Species,
                              Region=MERAfile[[3]]$Region,
                              Agency=MERAfile[[3]]$Agency,
                              MRfile=file.path('../MERA_library', basename(dir), paste0(basename(dir),'.mera')),
                              RPfile=file.path('../MERA_library', basename(dir), basename(dir),'index.html'),
                              hasMERA=TRUE,
                              hasRep=hasRep,
                              stringsAsFactors = FALSE)
  } else {
    missing <- c(missing, basename(dir))
  }
}

DF <- do.call('rbind', DFlist)
saveRDS(DF, "content/DF.rdata")

# make changes to library.Rmd if neccessary, then:
blogdown::build_site()


