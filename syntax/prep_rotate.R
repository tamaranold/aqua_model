# Image Recognition
# rotate images

# read packages
library(magick)
library(tidyverse)

# define path 
indir <- "C:/Users/nold_/Desktop/Bilder/ac/original/"
outdir <- "C:/Users/nold_/Desktop/Bilder/ac/train/"

# get folders 
infolder <- list.dirs(indir,
                      full.names = FALSE)[-1]

# initiate rotation
rotation <- c(0, 90, 180, 270)

# recreate each folder and rotate images
for(i in infolder){
  
  dir.create(paste0(outdir, i))
  file.rename(list.files(paste0(indir, i), full.names = TRUE),
              paste0(indir, i, "/", i, "_ac_train_", 1:length(list.files(paste0(indir, i))), ".jpg"))
  
  files <- list.files(paste0(indir, i))
  
  for(f in files){
    image <- image_read(paste0(indir, i, "/", f))
    
    for(r in rotation){
      img_rotate <- image_rotate(image, r)
      #rename
      nam <- str_replace(f, ".jpg", paste0("_", r, ".jpg"))
      #save
      image_write(img_rotate, 
                  paste0(outdir, i, "/", nam))
    }
  }
  
}
