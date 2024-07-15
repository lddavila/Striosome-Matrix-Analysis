%% load databases
home = cd("..\Pattern Analysis");
[dbs,twdbs] = loadData;
cd(home)
%% Create Skewness table
clc;
binSize = 100;
logOrNot = false;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
dictionary_of_edges = containers.Map('KeyType','char','ValueType','any');
dictionary_of_bin_counts = containers.Map('KeyType','char','ValueType','any');
for i=1:length(twdbs)
    disp(strcat("Database: ",namesOfDatabases(i)));
    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
    currentTaskTypes = uniqueTaskType;
    allSkews = [];
    for currentTaskType=1:length(currentTaskTypes)
        tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
        number_of_rats = size(unique(tableWithJust1TaskType.ratID),1);
        if strcmpi("CB",currentTaskTypes(currentTaskType))
            disp("CBC________________")
        elseif strcmpi("TR",currentTaskTypes(currentTaskType))
            disp("BB______________________")
        elseif strcmpi("Rev CB",currentTaskTypes(currentTaskType))
            disp("NCB_______________")
        elseif strcmpi("EQR",currentTaskTypes(currentTaskType))
            disp("CC_________________________________")
        end
        disp(strcat("Number Of Rats:",string(number_of_rats)))
        number_of_trials = height(tableWithJust1TaskType);
        disp(strcat("Number Of trials:",string(number_of_trials))); 
        disp(strcat("Number Of sessions by session id:",string(size(unique(tableWithJust1TaskType.sessionID),1))));
 
        number_of_cells = 0;
        just_mean_spike_wave_form_array = tableWithJust1TaskType.mean_spike_waveform;
        for k=1:height(tableWithJust1TaskType)
            current_mean_spike_wave_form_array = just_mean_spike_wave_form_array{i};
            number_of_cells = number_of_cells + size(current_mean_spike_wave_form_array,1);
        end
        disp(strcat("Number of cells:",string(number_of_cells)));
    end
    disp("/////////////////////////////////////")
end