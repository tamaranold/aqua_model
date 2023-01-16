# Image Recognition
# create testset

# set path
indir <- "./original/"
outdir <- "./test/"

# recreate folders
infolder <- list.dirs(indir,
                      full.names = FALSE)[-1]


map(infolder, ~ dir.create(paste0(outdir, .)))


# sample images for test 
for(i in infolder){
  
  img <- list.files(paste0(indir, i))
  
  imgsample <- sample(img, 20)
  
  file.rename(paste0(indir, i, "/", imgsample),
              paste0(outdir, i, "/", i, "_test_", 1:20, ".jpg"))
}
