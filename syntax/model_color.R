# Image Recognition 
# Model - color 

# load packages
library(tidyverse)
library(keras)
library(tensorflow)
library(reticulate)

# first use
#install_tensorflow(extra_packages="pillow")
#install_keras()

# set path 
traindir <- "C:/Users/nold_/Desktop/color/train/"
testdir <- "C:/Users/nold_/Desktop/color/test/"

# set number of categories
label_list_ac <- dir(traindir)
output_n_ac <- length(label_list_ac)

# resize images
width <- 150
height<- 150
target_size <- c(width, height)

# training and validation set 
path_train_ac <- traindir
train_data_gen_ac <- image_data_generator(validation_split = .2,
                                          rescale = 1/255)
train_images_ac <- flow_images_from_directory(path_train_ac,
                                              train_data_gen_ac,
                                              subset = 'training',
                                              target_size = target_size,
                                              class_mode = "categorical",
                                              shuffle= F,
                                              classes = label_list_ac,
                                              seed = 2022,
                                              color_mode = "rgb")


validation_images_ac <- flow_images_from_directory(path_train_ac,
                                                   train_data_gen_ac, 
                                                   subset = 'validation',
                                                   target_size = target_size,
                                                   class_mode = "categorical",
                                                   classes = label_list_ac,
                                                   seed = 2022, 
                                                   color_mode = "rgb")
## training set size
#table(train_images_ac$classes)

# train model
mod_base <- application_xception(weights = 'imagenet', 
                                 include_top = FALSE, 
                                 input_shape = c(width, height, 3))
freeze_weights(mod_base) 

model_function <- function(learning_rate = 0.001, 
                           dropoutrate=0.2, n_dense=1024){
  
  k_clear_session()
  
  model <- keras_model_sequential() %>%
    mod_base %>% 
    layer_global_average_pooling_2d() %>% 
    layer_dense(units = n_dense) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = n_dense/4) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = n_dense/8) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units=output_n_ac, activation="softmax")
  
  model %>% compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_adam(learning_rate = learning_rate),
    metrics = "accuracy"
  )
  
  return(model)
  
}

model <- model_function()
model


batch_size <- 32
epochs <- 25

hist <- model %>% fit(
  train_images_ac,
  steps_per_epoch = train_images_ac$n %/% batch_size, 
  epochs = epochs, 
  validation_data = validation_images_ac,
  validation_steps = validation_images_ac$n %/% batch_size,
  verbose = 2
)

save_model_tf(model, "model_color")

# evaluate model
path_test_ac <- testdir

test_data_gen_ac <- image_data_generator(rescale = 1/255)

test_images_ac <- flow_images_from_directory(path_test_ac,
                                             test_data_gen_ac,
                                             target_size = target_size,
                                             class_mode = "categorical",
                                             classes = label_list_ac,
                                             shuffle = F,
                                             seed = 2022,
                                             batch_size = 1, 
                                             color_mode = "rgb")

model %>% evaluate(test_images_ac, 
                   steps = test_images_ac$n)

# prediction
predictions_ac <- model %>% 
  predict(
    x = test_images_ac,
    steps = test_images_ac$n
  ) %>% as.data.frame

write.csv2(predictions_ac, "color_predicition.csv")

names(predictions_ac) <- paste0("Class",0:5)

predictions_ac$predicted_class <- 
  paste0("Class",apply(predictions_ac,1,which.max)-1)
predictions_ac$true_class <- paste0("Class",test_images_ac$classes)

predictions_ac %>% group_by(true_class) %>% 
  summarise(percentage_true = 100*sum(predicted_class == 
                                        true_class)/n()) %>% 
  left_join(data.frame(color= names(test_images_ac$class_indices), 
                       true_class=paste0("Class",0:5)),by="true_class") %>%
  select(color, percentage_true) %>% 
  mutate(color = fct_reorder(color,percentage_true)) %>%
  ggplot(aes(x=color,y=percentage_true,fill=percentage_true, 
             label=percentage_true)) +
  geom_col() + theme_minimal() + coord_flip() +
  geom_text(nudge_y = 3) + 
  ggtitle("Percentage correct classifications by color")

# save model
#save_model_tf(model, "model_ac_26percent")
