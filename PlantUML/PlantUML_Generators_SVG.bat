@echo off

title PlantUML_Generators_SVG.bat by Pitt Phunsanit

rem https://PlantUML.com/command-line

SET GeneratedImageType="-tsvg"
SET PlantUMLPath="C:\UsersGit\phunsanit\snippets\PlantUML"
SET sourcePath="Activity Diagram/"

echo Typing command cd to the location of folder PlantUML.jar and enter.
echo cd {your PlantUML.jar folder path} example:

set command=cd %PlantUMLPath%

echo %command%

call %command%

echo:
echo Typing command for running PlantUML
echo java -jar PlantUML.jar %GeneratedImageType% {your source path} . example:

set command=java -jar PlantUML.jar %GeneratedImageType% %sourcePath%

echo %command%

call %command%

echo:

cmd /k