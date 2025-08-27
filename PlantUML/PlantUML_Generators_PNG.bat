@echo off
title PlantUML_Generators_PNG.bat by Pitt Phunsanit

echo Typing command cd to the location of folder plantuml.jar and enter.
echo example
echo cd "C:\UsersGit\phunsanit\snippets\PlantUML"
echo:
echo Typing command for running PlantUML
echo java -jar PlantUML/plantuml.jar -png {your source path} . example:
echo java -jar PlantUML/plantuml.jar -png "Activity Diagram/"
echo:

cd "C:\UsersGit\phunsanit\snippets\PlantUML"

java -jar plantuml.jar -png "Activity Diagram"

cmd /k