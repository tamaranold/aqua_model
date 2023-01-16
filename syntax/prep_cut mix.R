# Image Recognition 
# Cut images into 36 single images

# load libraries
library(magick)
library(tidyverse)

# set path
indir <- "./mix/"
outdir <- "./single/"

# get image names 
files <- list.files(indir)

# cut image in tiles
for(n in files){
  # read image 
  img <-  image_read(paste0(indir, n))
  imgnum <- which(files %in% n)
  
  # describe dimension for cutting
  info <- image_info(img)
  width <- info$width/6
  height <- info$height/6
  
  # define cuttings
  mat <- data.frame(index = 1:36,
                    cell = rep(1:6, each = 6),
                    row = rep(1:6, 6),
                    nam = paste(rep(1:6, each = 6), 
                                rep(1:6, 6), sep = "_")) %>%
    mutate(width_end = cell * width,
           height_end = row * height,
           width_start = cell * width - width,
           height_start = row * height - height)
  
  # cut each image in 36 single images
  for(i in 1:nrow(mat)){
    
    # cutting positions
    window <- paste0(round(width, 0), "x", round(height,0), "+",
                     round(mat$width_start[i],0), "+", round(mat$height_start[i],0))
    # cut
    token <- image_crop(img, window)
    image_write(token,
                paste0(outdir, "img_8_", imgnum, "_", mat$nam[i], ".jpg"))
    assign(paste0("img_8_", imgnum, "_", mat$nam[i]), token)
  }
}



