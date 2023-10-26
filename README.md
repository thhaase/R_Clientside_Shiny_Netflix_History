# R_Clientside_Shiny_Netflix_History

## Hosting Shiny Apps Clientside with Github Pages

With the help of [this Tutorial](https://github.com/RamiKrispin/shinylive-r) I published my little [Netflix-Plots Dashboard Project](https://github.com/thhaase/Netflix_History_Dashboard) as a clientside Application via Github Pages. 

The linked tutorial has some typos in the code. I included the (very few) lines of code for creating the files in the docs folder at the top of my app.R

## Summarizing the tutorial:

1. Make 2 new folders called "app" and "docs" in your main folder.
2. Rename the shiny-app file to "app.R" and move it into the "app" folder
3. Now open the "app.R" in R-Studio and execute the following via the console:
```R
library(shinylive)
```  
after that
```R
shinylive::export(appdir = "app", destdir = "docs")
```

4. Now head over to Github and make your repository with the two folders public
5. In the "settings" of the repository open the github-pages tab on the left side
6. As the "Branch" choose "main", after that "docs" and then save your choice
7. Now wait a few minutes, reload the page and you will see the link on top of the "pages" tab wich you can use to access the shiny-app
 
## Better then shinyapps.io?
Despite the downside of **extremely long** time it takes to load this is by far the better method for publishing small apps like this one for friends or colleagues then using shinyapps.io (like i did before). Keep in mind that the free tier of shinyapps.io is also only made for small and simple projects.
This method is as fast to deploy like shinyapps.io and because of the the nature of the shiny-server being clientside its possible to make your project public and keep the link up for eternity. 

#### Try the Netflix-Plot Dashboard out for yourself! 
Make yourself a tea, it takes a while to load.
Here is the Link for the Dashboard: https://thhaase.github.io/R_Clientside_Shiny_Netflix_History/
