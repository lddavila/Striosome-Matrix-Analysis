% Specify the folder where the files live.
myFolder = "Control Lines";
% myFolder = "Stress Lines";
% myFolder = "Stress 2 Lines";
rsquaredThreshold = 0.2;
significanceThreshold = 0.05; 

satisfactoryRsquaredCount = containers.Map('KeyType','char','ValueType','any');
satisfactorySignificance = containers.Map('KeyType','char','ValueType','any');
totalFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalNegativeFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalPositiveFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalPositiveRSquaredSatisfactory = containers.Map('KeyType','char','ValueType','any');
totalPositiveSignificance =containers.Map('KeyType','char','ValueType','any');



% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '**/*.fig'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for a=1: length(theFiles)
    baseFileName = theFiles(a).name;
    fullFileName = fullfile(theFiles(a).folder, baseFileName);
    splitFileName = split(fullFileName,'\');
%     display(splitFileName)
    satisfactoryRsquaredCount(string(splitFileName(8)))= 0;
    satisfactorySignificance(string(splitFileName(8)))= 0;
    totalFiguresCount(string(splitFileName(8))) = 0;
    totalNegativeFiguresCount(string(splitFileName(8))) =0 ;
    totalPositiveFiguresCount(string(splitFileName(8))) = 0;
    totalPositiveRSquaredSatisfactory(string(splitFileName(8))) = 0;
    totalPositiveSignificance(string(splitFileName(8))) =0;
end
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    splitFileName = split(fullFileName,'\');
%     display(splitFileName)
    fprintf(1, 'Now reading %s\n', fullFileName);
    currentTitle = string(splitFileName(10));
    currentTitle = split(currentTitle," ");
    rsquared = currentTitle(10);
    rsquared = str2double(rsquared);
    significance = currentTitle(12);
    significance = strrep(significance,".fig","");
    significance = str2double(significance);
%     display(currentTitle)
%     disp(rsquared)
%     disp(significance)
    if strcmp(string(splitFileName(9)),"Negative Slope")
        totalFiguresCount(string(splitFileName(8))) = totalFiguresCount(string(splitFileName(8)))+1;
        totalNegativeFiguresCount(string(splitFileName(8))) = totalNegativeFiguresCount(string(splitFileName(8)))+1;
        if significance <= significanceThreshold
            if rsquared >=rsquaredThreshold
                satisfactoryRsquaredCount((string(splitFileName(8)))) = satisfactoryRsquaredCount((string(splitFileName(8)))) +1;
                satisfactorySignificance((string(splitFileName(8)) )) = satisfactorySignificance((string(splitFileName(8)) ))+1;
            end
        end
        
    else
        totalFiguresCount(string(splitFileName(8))) = totalFiguresCount(string(splitFileName(8)))+1;
        totalPositiveFiguresCount(string(splitFileName(8))) = totalPositiveFiguresCount(string(splitFileName(8)))+1;
        if rsquared >= rsquaredThreshold
            if significance<=significanceThreshold
                totalPositiveRSquaredSatisfactory(string(splitFileName(8))) = totalPositiveRSquaredSatisfactory(string(splitFileName(8)))+1;
                totalPositiveSignificance(string(splitFileName(8))) =totalPositiveSignificance(string(splitFileName(8))) +1;
            end
        end

    end
   
end