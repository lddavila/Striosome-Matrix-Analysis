%this file automatically finds and identifies striosome-matrix neuron pairs
%it then uses matrix_strio_plot_dynamics.m to fit the firing rates with a
%linear object
%then it saves the created figure in the appropriate folder 

workingDIR = cd('Extracting Data From TWDB');
extractingData = cd(workingDIR);


%cycle through all the concentrations and task types in the current
%database
%uniqueConcentrations - an int array of all concentrations in currentDatabase, created by getAllUniqueValuesInTWDBControl.m
%uniqueTaskType - an string array of all task types in currentDatabase, created by getAllUniqueValuesInTWDBControl.m 
for currentConcentration=1:length(uniqueConcentrations)
    for currentTaskType=1:height(uniqueTaskType)
        newDir = strcat("Line ","Task Type ",string(uniqueTaskType(currentTaskType))," Concentration ",string(uniqueConcentrations(currentConcentration)));
        mkdir(newDir)
        cd(extractingData)
%     
        %look up striosomes in the current database
        striosomes_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ...
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
            'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
            'key','taskType',uniqueTaskType{currentTaskType},...
            'key','conc',uniqueConcentrations(currentConcentration));    
        
        %look up matrix neurons in the current database
        matrix_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ...
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 1, ...
            'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
            'key','taskType',uniqueTaskType{currentTaskType},...
            'key','conc',uniqueConcentrations(currentConcentration));

        %identify which matrix-striosome pairs 
        %this is accomplished by checking if the current matrix and
        %striosome both belong to the same rat and the same session 
        matrix_indexes = [];
        striosome_indexes = [];
        striosome_matrix_pairs = [];
        for matrix_counter =1: length(matrix_ids)
            matrix_index = matrix_ids(matrix_counter);
            matrix_index = str2double(matrix_index);
            currentData=currentDataBase(matrix_index);
            session = currentData.sessionID;
            rat = currentData.ratID;
            tetrodeN = currentData.tetrodeN;
            for striosome_counter = 1: length(striosomes_ids)
                striosome_index = striosomes_ids(striosome_counter);
                striosome_index = str2double(striosome_index);
                striosome_data = currentDataBase(striosome_index);
                striosome_session = striosome_data.sessionID;
                striosome_rat = striosome_data.ratID;
                striosome_tetrode=striosome_data.tetrodeN;
                if strcmp(striosome_rat,rat) && strcmp(striosome_session,session) %&& strcmp(tetrodeN,striosome_tetrode)
                    matrix_indexes = [matrix_indexes;matrix_index];
                    striosome_indexes = [striosome_indexes;striosome_index];
                end
            end
        end
        striosome_matrix_pairs = [striosome_indexes,matrix_indexes];
        cd(workingDIR)


        %Now call matrix_strio_plot_dynamics.m for each pair 
        %save the created figure into the appropriate folder depending on
        %the figure's slope
        currentIndex=1;
        striosome_bin_time = 1;
        disp(strcat("Task Type: ",string(uniqueTaskType(currentTaskType))," ",...
            "Concentration: ",string(uniqueConcentrations(currentConcentration)), ...
            "Has The following Number of Pairs: ",string(height(striosome_matrix_pairs))));
        while currentIndex <= height(striosome_matrix_pairs)

            figure
            spikes_strio=currentDataBase(striosome_matrix_pairs(currentIndex,1)).trial_spikes;
            spikes_matrix=currentDataBase(striosome_matrix_pairs(currentIndex,2)).trial_spikes;

            [given_fig,gof,significance,slope] = matrix_strio_plot_dynamics(spikes_strio,spikes_matrix,striosome_bin_time);
            currentDir =cd(newDir);
            thename = strcat("T T ", string(uniqueTaskType(currentTaskType)), ...
                " Conc ",string(uniqueConcentrations(currentConcentration)), ...
                " Pair Row ",string(currentIndex), ...
                " RSq ", string(gof),...
                " Sig ", string(significance), ...
                '.fig');
            %            thename = strcat(pwd,thename);
            subtitle(thename)
            %                display(thename)
            try
                mkdir("Positive Slope")
                mkdir("Negative Slope")
                if slope>0
                    cd("Positive Slope");
                    saveas(given_fig,thename)
                    disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex)));
                elseif slope<0
                    cd("Negative Slope");
                    saveas(given_fig,thename)
                    disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex)));
                elseif significance ==100
                    disp(strcat("Failed in Analyzing Pair: ",string(currentIndex)));
                end
            catch
                if slope>0
                    cd("Positive Slope");
                    saveas(given_fig,thename)
                    disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex)));
                elseif slope<0
                    cd("Negative Slope");
                    saveas(given_fig,thename)
                    disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex)));
                elseif significance==100
                    disp(strcat("Failed in Analyzing Pair: ",string(currentIndex)));
                end

            end
            %                pause(20)

            currentIndex=currentIndex+1;
            close(given_fig)
            cd(currentDir)



        
        end
    end
end




