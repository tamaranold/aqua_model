# aqua_model

As an avid board gamer, I love planning and deliberating moves. But counting points at the end is less fun. With the auqa projects I want to automate this part for the [Aqualin](https://boardgamegeek.com/boardgame/295948/aqualin) game.

In Auqalin, two players place colorful underwater animals on a common game board to end up with the largest swarms. There are 36 tokens, six animals in six different colors. One player is trying to place the same animals next to each other, the other is making groups in the same color. At the end, someone has to count the swarm sizes. And this is where this project begins. 

In the **auqa_model** project, image recognition models are trained to classify each token on the board by color and animal. In the **aqua_win** project, these algorithms are used inside an app to calculate the scores and determine the winner. 

# collecting images and preparing datasets

Images for training and testing were taken by myself. All tokens were randomly placed on the game board. The images were taken of the whole board and cropped with R ([code](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_cut%20mix.R)). Two datasets with the same images were created, one sorted by animals (crab, fish, jellyfish, seahorse, starfish, tortoise) and one sorted by color (blue, green, red, pink, purple, yellow).  

720 images (120 for each of the 6 categories) were sampled for the test dataset ([code](https://github.com/tamaranold/aqua_model/blob/f5eb6b63d1706c3b280370c0e7285cfa3641d07b/syntax/create_testset.R)). Preprocessing for the training dataset contained rotating each image by 0, 90, 180 and 270 degrees ([code](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/prep_rotate.R)). Each category included between 2756 and 2992 images. 80% of the images were used as testing dataset, 20% as validation dataset. 

Considering possible copyright issues, the datasets/images used are not uploaded to this project.

# analysis

Two models were fitted - one for each player ([code animal] (https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/model_animal.R); [code color](https://github.com/tamaranold/aqua_model/blob/42c7dc5298f3399c1a1e03eb38dad05e32ad2227/syntax/model_color.R)). 

## animal model

The animal prediction model showed an accuracy 95%. Starfishes are easily recognizable with an accuracy of 99%, whereas the slim seahorse is more difficult to identify with an accuracy of 89%. 

![animal_classfication](https://user-images.githubusercontent.com/38466492/196999622-f8a4cbb5-6ae5-44f1-a0ae-d00788960318.svg)

## color model

The model for color recognition had an accuracy of 78%. 

![color_classification](https://user-images.githubusercontent.com/38466492/196999542-212a258f-a546-4103-8abf-a6e61195899a.svg)

# further ideas

Using the models as they are might lead to an (dis-)advantage for the color player. A second code will be needed for checking and adjusting the quotes of each category based on their probabilities - each animal and color occurs exactly 6 times. 

# sources 

This is my first time fitting an image recognition model therefore I used [this](https://www.r-bloggers.com/2021/03/how-to-build-your-own-image-recognition-app-with-r-part-1/) blog post by ApokalypsePartyTeam as a template.

# lessons learned - the not-to-do list

- don't underestimate the amount of images needed to train the model: In my naive mind the animals and colors seemed easy to distinguish and therefore hundreds of images won't be needed. I was wrong. 
- don't be too fixated to fit the one model: I planned one model to classify all 36 tokens. Many categories mean more time to process, more images and more aborted R sessions. Two models (one for animals and one for colors) will do it either. 
- don't ignore the hardware: My older laptop needed over an hour for one epoch, the new one needed six minutes.  
