# aqua_model

As an avid board gamer, I love planning and deliberating moves. But counting points at the end is less fun. With the auqa projects I want to automate this part for the [Aqualin](https://boardgamegeek.com/boardgame/295948/aqualin) game.

In Auqalin, two players place colorful underwater animals on a common game board to end up with the largest swarms. There are 36 tokens, six animals in six different colors. One player is trying to place the same animals next to each other, the other is making groups in the same color. At the end, someone has to count the swarm sizes. And this is where this project begins.

In the **auqa_model** project, image recognition models are trained to classify each token on the board by color and animal. In the **aqua_win** project, these algorithms are used inside an app to calculate the scores and determine the winner.

# collecting images and preparing datasets
Images for training and testing were taken by myself. All tokens were randomly placed on the board with different lighting conditions. The images were taken of the whole board (all 36 tokens) and cropped with R ([code](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_cut%20mix.R)).

Approximately 125 images of tokens for each of the 36 categories were sampled for the train and test sets ([code cut](https://github.com/tamaranold/aqua_model/blob/f5eb6b63d1706c3b280370c0e7285cfa3641d07b/syntax/create_testset.R) ). Preprocessing for the training dataset contained rotating each image by 0, 90, 180 and 270 degrees ([code prep](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_rotate.R) ). 80% of the images were used as testing dataset, 20% as validation dataset. The training set contained 13919 images, the validation set 3460 and the test set 720 images.

Images for training and testing were taken by myself. All tokens were randomly placed on the game board. The images were taken of the whole board and cropped with R ([code](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_cut%20mix.R)). Two datasets with the same images were created, one sorted by animals (crab, fish, jellyfish, seahorse, starfish, tortoise) and one sorted by color (blue, green, red, pink, purple, yellow).  

720 images (120 for each of the 6 categories) were sampled for the test dataset ([code](https://github.com/tamaranold/aqua_model/blob/f5eb6b63d1706c3b280370c0e7285cfa3641d07b/syntax/create_testset.R) ). Preprocessing for the training dataset contained rotating each image by 0, 90, 180 and 270 degrees ([code](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_rotate.R) ). Each category included between 2756 and 2992 images. 80% of the images were used as testing dataset, 20% as validation dataset. 

Considering possible copyright issues, the datasets/images used are not uploaded to this project.

# analysis 

A model to recognize and predict all 36 tokens was build, XXCODE

Two models were fitted - one for each player
([code model](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/model_animal.R) ; [code color](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/model_color.R)). 
>>>>>>> c6453d4efd5a54245d7a0167f27c8d3f4c8b6486

The model has an accuracy of 98.88%. Most classes were predicted correctly, just eight of 720 test images where wrongly assigned.

XXIMAGE

Low image quality seems to be the common reason for false prediction. 

| test token (true class_image number) | predicted class | features                                                     |
|---------------------------------------|-----------------|----------------|
| pink_crab_2                          | yellow_crab     | the lighting makes the color look more orange than pink      |
| pink_crab_4                          | red_crab        | bad lighting, image is quite dark                            |
| purple_crab_15                       | purple_seahorse | image is cropped, not even showing half of the crab          |
| red_fish_1                           | pink_fish       | color hardly recognizable because of strong light reflection |
| red_fish_14                          | pink_jellyfish  | image hardly recognizable because of strong light reflection |
| blue_seahorse_10                     | green_seahorse  | image hardly recognizable because of strong light reflection |
| green_seahorse_19                    | jellyfish_red   | bad lighting, image is dark                                  |
| blue_tortoise_15                     | fish_blue       | actually blue fish, token in wrong test class                |

# sources

This is my first time fitting an image recognition model therefore I used [this](https://www.r-bloggers.com/2021/03/how-to-build-your-own-image-recognition-app-with-r-part-1/) blog post by ApokalypsePartyTeam as a template.
