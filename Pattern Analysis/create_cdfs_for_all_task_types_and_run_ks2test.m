%% load databases
[dbs,twdbs] = loadData;
%% Create CDFS
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
allTaskTypesAndConcentrationsPairedWith20thPercentiles = containers.Map('KeyType','char','ValueType','any');
allTaskTypesAndConcentrationsPairedWith90thPercentiles = containers.Map('KeyType','char','ValueType','any');
figure; hold on;
string_that_will_be_used_for_legend = [];

map_of_all_col_6 = containers.Map('KeyType','char','ValueType','any');
for i=1:3.5%length(twdbs)
    if i==3
        continue;
    else 
        
    end

    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
    %     disp(i)
    %     disp(uniqueConcentrations)
    %     disp(uniqueTaskType)
    currentTaskTypes = uniqueTaskType;


    for currentTaskType=1:length(currentTaskTypes)
        hold on;
        if strcmp(currentTaskTypes(currentTaskType),"EQR") || strcmp(currentTaskTypes(currentTaskType),"Rev CB")
            continue
        end

        tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
        currentConcentrations = unique(tableWithJust1TaskType.conc);
        currentConcentrations = rmmissing(currentConcentrations);
        currentConcentrations = []; 
        if ~isempty(currentConcentrations)
            allSkews = [];
            %             for currentConcentration=1:length(currentConcentrations)
            modifiedTable = tableWithJust1TaskType(currentConcentrations(currentConcentration) == tableWithJust1TaskType.conc,:);
            %             disp(strcat("Expected Task Type: ",string(currentTaskTypes(currentTaskType))," Expected Concentration",string(currentConcentrations(currentConcentration))))
            %             disp(table(modifiedTable.taskType,modifiedTable.conc))
            allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
            %             disp(size(allTimingsInsideModifiedTable,1))
            allCol6InModifedTable = [];
            for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
            end
            %             disp(allCol6InModifedTable)
            if ~isempty(allCol6InModifedTable)
                cdfplot(allCol6InModifedTable)
                map_of_all_col_6(strcat(dbs{i},string(currentTaskTypes(currentTaskType)))) = allCol6InModifedTable;
                allTaskTypesAndConcentrationsPairedWith90thPercentiles(strcat(string(currentTaskTypes(currentTaskType))," ",string(currentConcentrations(currentConcentration)))) = prctile(allCol6InModifedTable,90);
                allTaskTypesAndConcentrationsPairedWith20thPercentiles(strcat(string(currentTaskTypes(currentTaskType))," ",string(currentConcentrations(currentConcentration)))) = prctile(allCol6InModifedTable,20);
                allSkews = [allSkews,skewness(allCol6InModifedTable)];
            end
            %             end
        else
            string_that_will_be_used_for_legend = [string_that_will_be_used_for_legend,strcat(dbs{i},string(currentTaskTypes(currentTaskType)))];
            modifiedTable = t((strcmp(string(tableWithJust1TaskType.taskType),string(currentTaskTypes(currentTaskType)))),:);
            allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
            %             disp(size(allTimingsInsideModifiedTable,1))
            allCol6InModifedTable = [];
            for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
            end
            %             disp(allCol6InModifedTable)
            if ~isempty(allCol6InModifedTable)
                cdfplot(allCol6InModifedTable)
                map_of_all_col_6(strcat(dbs{i},string(currentTaskTypes(currentTaskType)))) = allCol6InModifedTable;
                allTaskTypesAndConcentrationsPairedWith90thPercentiles(strcat(string(currentTaskTypes(currentTaskType)))) = prctile(allCol6InModifedTable,90);
                allTaskTypesAndConcentrationsPairedWith20thPercentiles(strcat(string(currentTaskTypes(currentTaskType)))) = prctile(allCol6InModifedTable,20);
            end
            allSkews = skewness(allCol6InModifedTable);
        end

        allConcentrationsAsStrings = num2str(currentConcentrations);
        allConcentrationsAsStringsPlusSkewness = {};
        if ~isempty(currentConcentrations)
            for currentRow=1:height(allConcentrationsAsStrings)
                allConcentrationsAsStringsPlusSkewness{currentRow} = strcat(string(allConcentrationsAsStrings(currentRow,:))," Skewness: ",string(allSkews(currentRow)));
                allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration ",string(currentConcentrations(currentRow)))) = allSkews(currentRow);
            end
            legend(allConcentrationsAsStringsPlusSkewness)
        else
            legend(strcat("Skewness: ", string(allSkews)))
            allTaskTypesAndConcentrationsPairedWithSkewness('Task Type EQR') = allSkews;
        end


        % title(string(dbs(i)))
        xlim([0,20])
%         hold off
    end
    
%     hold off;
end

for i=1:length(string_that_will_be_used_for_legend)
    first_experiment = string_that_will_be_used_for_legend(i);
    first_experiment_data = map_of_all_col_6(first_experiment);
    for j=i+1:length(string_that_will_be_used_for_legend)
        second_experiment = string_that_will_be_used_for_legend(j);
        second_experiment_data = map_of_all_col_6(second_experiment);
        [h,p] = kstest2(first_experiment_data,second_experiment_data,'Alpha',0.0001);
        fprintf("%s compared to %s:\n h:%d,p:%d\n",first_experiment,second_experiment,h,p);
    end
end



[h1_for_CB,p_for_CB_1] = kstest2(map_of_all_col_6("controlCB"),map_of_all_col_6("stressCB"),'Alpha',0.0001);
[h2_for_TR,p_for_TR_2] = kstest2(map_of_all_col_6("controlTR"),map_of_all_col_6("stressTR"),'Alpha',0.0001);

legend(string_that_will_be_used_for_legend)
% disp(string_that_will_be_used_for_legend)
title(["Control and Stress",strcat("Con CB vs Stress CB: h:,",string(h1_for_CB)," p:",string(p_for_CB_1)),strcat("Con TR vs Stress TR: h:,",string(h2_for_TR)," p:",string(p_for_TR_2))]);
subtitle("Created by create\_cdfs\_for\_all\_task\_types\_and\_run\_ks2test.m");