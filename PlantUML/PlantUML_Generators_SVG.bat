@echo off
title PlantUML_Generators_SVG.bat by Pitt Phunsanit

echo Typing command cd to the location of folder plantuml.jar and enter.
echo example
echo cd "C:\UsersGit\phunsanit\snippets\PlantUML"
echo:
echo Typing command for running PlantUML
echo java -jar PlantUML/plantuml.jar -svg {your source path} . example:
echo java -jar PlantUML/plantuml.jar -svg "Activity Diagram/"
echo:

cd "C:\UsersGit\phunsanit\snippets\PlantUML"

java -jar plantuml.jar -svg "Activity Diagram"

cmd /k