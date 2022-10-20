# Image Recognition 
# Model - animal prediction 

# load packages
library(tidyverse)
library(keras)
library(tensorflow)
library(reticulate)

# first use
#install_tensorflow(extra_packages="pillow")
#install_keras()

# set path 
traindir <- ".../train/"
testdir <- ".../test/"

# set number of categories
label_list_a <- dir(traindir)
output_n_a <- length(label_list_a)

# resize images
width <- 150
height<- 150
target_size <- c(width, height)

# training and validation set 
path_train_a <- traindir
train_data_gen_a <- image_data_generator(validation_split = .2,
                                          rescale = 1/255)
train_images_a <- flow_images_from_directory(path_train_a,
                                              train_data_gen_a,
                                              subset = 'training',
                                              target_size = target_size,
                                              class_mode = "categorical",
                                              shuffle= F,
                                              classes = label_list_a,
                                              seed = 2022,
                                              color_mode = "rgb")


validation_images_a <- flow_images_from_directory(path_train_a,
                                                   train_data_gen_a, 
                                                   subset = 'validation',
                                                   target_size = target_size,
                                                   class_mode = "categorical",
                                                   classes = label_list_a,
                                                   seed = 2022, 
                                                   color_mode = "rgb")
## training set size
#table(train_images_a$classes)

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
    layer_dense(units=output_n_a, activation="softmax")
  
  model %>% compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_adam(learning_rate = learning_rate),
    metrics = "accuracy"
  )
  
  return(model)
  
}

model_a <- model_function()
model_a


# start training process
batch_size <- 32
epochs <- 15

hist <- model_a %>% fit(
  train_images_a,
  steps_per_epoch = train_images_a$n %/% batch_size, 
  epochs = epochs, 
  validation_data = validation_images_a,
  validation_steps = validation_images_a$n %/% batch_size,
  verbose = 2
)

## save model
save_model_tf(model_a, "model_animal")

# evaluate model
path_test_a <- testdir

test_data_gen_a <- image_data_generator(rescale = 1/255)

test_images_a <- flow_images_from_directory(path_test_a,
                                             test_data_gen_a,
                                             target_size = target_size,
                                             class_mode = "categorical",
                                             classes = label_list_a,
                                             shuffle = F,
                                             seed = 2022,
                                             batch_size = 1, 
                                             color_mode = "rgb")

model_a %>% evaluate(test_images_a, 
                   steps = test_images_a$n)

# prediction
predictions_a <- model_a %>% 
  predict(
    x = test_images_a,
    steps = test_images_a$n
  ) %>% as.data.frame

## save prediciton matrix
write.csv2(predictions_a, "animal_predicition.csv")


# plot predition of each category
names(predictions_a) <- paste0("Class",0:5)

predictions_a$predicted_class <- 
  paste0("Class",apply(predictions_a,1,which.max)-1)
predictions_a$true_class <- paste0("Class",test_images_a$classes)

predictions_a %>% 
group_by(true_class) %>% 
  summarise(percentage_true = 100*sum(predicted_class == 
                                        true_class)/n()) %>% 
  left_join(data.frame(color= names(test_images_a$class_indices), 
                       true_class=paste0("Class",0:5)),by="true_class") %>%
  select(color, percentage_true) %>% 
  mutate(color = fct_reorder(color,percentage_true)) %>%
  ggplot(aes(x=color,y=percentage_true,fill=percentage_true, 
             label=percentage_true)) +
  geom_col() + 
  theme_minimal() + 
  coord_flip() +
  geom_text(nudge_y = 3) + 
  ggtitle("Percentage correct classifications by animal")
