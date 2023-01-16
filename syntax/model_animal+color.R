# Image Recognition
# Code based on: https://www.r-bloggers.com/2021/03/how-to-build-your-own-image-recognition-app-with-r-part-1/

# load packages
library(tidyverse)
library(keras)
library(tensorflow)
library(reticulate)

# first use of tensorflow and keras
#install_tensorflow(extra_packages="pillow")
#install_keras()

# set path
traindir <- "C:/Users/nold_/Desktop/animal+color/train/"
testdir <- "C:/Users/nold_/Desktop/animal+color/test/"

# define datasets --------------------------------------------------------------
# set number of categories
label_list <- dir(traindir)
output_n <- length(label_list)

# resize images
width <- 150
height <- 150
target_size <- c(width, height)

# define training and validation set
path_train <- traindir
train_data_gen <- image_data_generator(validation_split = .2,
                                       rescale = 1 / 255)
train_images <- flow_images_from_directory(
  path_train,
  train_data_gen,
  subset = 'training',
  class_mode = "categorical",
  classes = label_list,
  seed = 123,
  target_size = target_size,
  color_mode = "rgb"
)

validation_images <- flow_images_from_directory(
  path_train,
  train_data_gen,
  subset = 'validation',
  class_mode = "categorical",
  classes = label_list,
  seed = 123,
  target_size = target_size,
  color_mode = "rgb"
)

# define model -----------------------------------------------------------------
# load pre-trained model, model final layer with owen dataset by include_top = F
mod_base <- application_xception(
  weights = 'imagenet',
  include_top = FALSE,
  input_shape = c(256, 256, 3)
)

model_function <- function(learning_rate = 0.001,
                           dropoutrate = 0.2,
                           n_dense = 1024) {
  k_clear_session()
  
  model <- keras_model_sequential() %>%
    mod_base %>%
    layer_global_average_pooling_2d() %>%
    layer_dense(units = n_dense) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = n_dense / 4) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = n_dense / 8) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = output_n, activation = "softmax")
  
  model %>% compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_adam(learning_rate = learning_rate),
    metrics = "accuracy"
  )
  
  return(model)
  
}

# show model
model <- model_function()
model

# train model ------------------------------------------------------------------
batch_size <- 32
epochs <- 10

hist <- model %>% fit(
  train_images,
  steps_per_epoch = train_images$n %/% batch_size,
  epochs = epochs,
  validation_data = validation_images,
  validation_steps = validation_images$n %/% batch_size,
  verbose = 2
)

# save model
save_model_hdf5(model,
                "C:/Users/nold_/Desktop/model/animal+color_model2.hdf5")

# evaluate model ---------------------------------------------------------------
path_test <- testdir

test_data_gen <- image_data_generator(rescale = 1 / 255)

test_images <- flow_images_from_directory(
  path_test,
  test_data_gen,
  target_size = target_size,
  class_mode = "categorical",
  classes = label_list,
  shuffle = F,
  seed = 2022,
  batch_size = 1,
  color_mode = "rgb"
)

model %>% evaluate(test_images,
                   steps = test_images$n)

# predict test images ----------------------------------------------------------
predictions <- model %>%
  predict(x = test_images,
          steps = test_images$n) %>% as.data.frame

# save predictions
write.csv2(predictions, "animal+color_predicition.csv")

# plot accuracy for each token
names(predictions) <- paste0("Class", 0:35)

predictions$predicted_class <-
  paste0("Class", apply(predictions, 1, which.max) - 1)
predictions$true_class <- paste0("Class", test_images$classes)

predictions %>% group_by(true_class) %>%
  summarise(percentage_true = 100 * sum(predicted_class ==
                                          true_class) / n()) %>%
  left_join(data.frame(
    animal = names(test_images$class_indices),
    true_class = paste0("Class", 0:35)
  ), by = "true_class") %>%
  select(animal, percentage_true) %>%
  mutate(animal = fct_reorder(animal, percentage_true)) %>%
  ggplot(aes(
    x = animal,
    y = percentage_true,
    fill = percentage_true,
    label = round(percentage_true, 0)
  )) +
  geom_col(show.legend = FALSE) +
  geom_text(nudge_y = 3) +
  labs(x = "token (animal_color)",
       y = "percentage of correctly predicted tokens",
       title = "Model accuracy for each token") +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  theme_minimal() +
  theme(plot.title.position = "plot") +
  coord_flip()
