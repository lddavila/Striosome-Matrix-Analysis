%% load databases
[dbs,twdbs] = loadData;
%% test
namesOfDatabases = ["Control","Stress1","Stress2"];
for currentDB = 2:2.5%length(twdbs)
    map_of_total_pairs_by_task_type = containers.Map('KeyType','char','ValueType','any');
    currentDatabase = twdbs{currentDB};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
%     disp(uniqueTaskType)




    for ttCounter = 1:length(uniqueTaskType)
        allTheFirstStriosomeActivityByTaskType = [];
        currentTaskType = uniqueTaskType{ttCounter};
        disp(strcat("Current Task Type:", currentTaskType))
        tableWithOnlyCurrentTaskType =  t((strcmp(string(t.taskType),string(uniqueTaskType(ttCounter)))),:);

        cd("..\Pattern Analysis")
        [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],NaN); %find neuron Ids
        %         disp(cb_strio_ids{1})
        %         disp(cb_matrix_ids{1})
        cd("..\Pattern Analysis")
        [~,sessionDir_neurons] = findAllSessions(twdbs,dbs);
        % cd("..\Pattern Analysis")

        %         %% Get Pairs
% 
%         if isempty(cb_strio_ids{2})
%             continue
%         end
        % display(cb_strio_ids)
        cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
        [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);  %%IMPORTANT
                                                                                                                          %%LINE 62 tells you what specifically you are looking for
                                                                                                                          % by changing what ids you are putting in you change what pairs you are looking at
                                                                                                                          %the original line is the following
                                                                                                                          %[neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
                                                                                                                          %it looks for matrix-striosome pairs
                                                                                                                          %by changing it you can look for strio-strio or matrix-matrix pairs as well
        all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);
        %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
        all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);
        nlags=1;

        %         %% The important part
        % I still need to keep track of Patterns,
        %but now I need to specify where each count is goooooooing
        %it can only be a short trial or a long trial
        %where short is anything less than or equal to 2.49329
        %and long is anything less than or equal to 4.46383 but still greater than the short trial
        %these numbers are hardcoded into plotBins.m and can be changed if the need ever arises
        %the variable shortOrLong tells us which this is
        %shortOrLong=0 : short Trial
        %shortOrLong=1: long trial
        %shortOrLong=2: this is an edge case which indicates that the trial was unusually long, likely due to artifact
        %the variable pairedOrUnpaired tells us whether or not granger causality detected the pairs to be connected or not
        %pairedOrUnpaired =1: paired
        %pairedOrUnpaired =0: unpaired

        %the structure of the following variables is as follows
        %TrialCounter(databaseNumber)(Pattern You are Counting)
        %databaseNumber = 1 - control
        %databaseNumber = 2 - stress
        %databaseNumber = 3 - stress 2
        %Pattern You Are Counting = 1: striosome excited, matrix excited
        %Pattern You Are Counting = 1: striosome excited, matrix inhibited
        %Pattern You Are Counting = 1: striosome inhibited, matrix excited
        %Pattern You Are Counting = 1: striosome inhibited, matrix inhibited


        %first number represents short count
        %second number reresents longCount
        %each cell array represents a database
        pairedShortAndLongCount = {{0,0},{0,0},{0,0}};
        unpairedShortAndLongCount = {{0,0},{0,0},{0,0}};

        currentDatabasePairs = all_matrix_strio_pairs{currentDB};
        currentDatabase = twdbs{currentDB};

        connectedCount=0;
        for currentPair=1:height(currentDatabasePairs)
            cd("..\Pattern Analysis")
            if runGrangerCausality_modified_to_count_connected_pairs(currentPair,currentDatabase,currentDatabasePairs,nlags)
                connectedCount = connectedCount+1;
            end
        end
        map_of_total_pairs_by_task_type(currentTaskType) = connectedCount;

    end

    disp([keys(map_of_total_pairs_by_task_type).',values(map_of_total_pairs_by_task_type).'])


end