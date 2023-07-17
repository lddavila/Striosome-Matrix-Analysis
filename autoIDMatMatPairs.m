%this file automatically finds and identifies matrix-matrix neuron pairs
%it then uses mat_mat_plot_dynamics.m to fit the firing rates with a
%linear object
%then it saves the created figure in the appropriate folder 

workingDIR = cd('Extracting Data From TWDB');
extractingData = cd(workingDIR);
currentDataBase = twdb_control;

%cycle through all the concentrations and task types in the current
%database
%uniqueConcentrations - an int array of all concentrations in currentDatabase, created by getAllUniqueValuesInTWDBControl.m
%uniqueTaskType - an string array of all task types in currentDatabase, created by getAllUniqueValuesInTWDBControl.m 
for currentConcentration=1:length(uniqueConcentrations)
    for currentTaskType=1:height(uniqueTaskType)
        newDir = strcat("Line ","Task Type ",string(uniqueTaskType(currentTaskType))," Concentration ",string(uniqueConcentrations(currentConcentration)));
        mkdir(newDir)
        cd(extractingData)
        
        %look up matrix neurons in the current database
        matrix_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ...
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 1, ...
            'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
            'key','taskType',uniqueTaskType{currentTaskType},...
            'key','conc',uniqueConcentrations(currentConcentration));

        
        %identify matrix-matrix pairs 
        %this is accomplished by checking if the current matrix and
        %striosome both belong to the same rat and the same session 
        matrix_indexes = [];
        matrix2_indexes = [];
        matrix_matrix_pairs = [];
        for matrix1_counter =1: length(matrix_ids)
            matrix1_index = matrix_ids(matrix1_counter);
            matrix1_index = str2double(matrix1_index);
            currentData=currentDataBase(matrix1_index);
            session = currentData.sessionID;
            rat = currentData.ratID;
            tetrodeN = currentData.tetrodeN;
            for matrix2_counter = matrix1_counter+1: length(matrix_ids)
                matrix2_index = matrix_ids(matrix2_counter);
                matrix2_index = str2double(matrix2_index);
                matrix2_data = currentDataBase(matrix2_index);
                matrix2_session = matrix2_data.sessionID;
                matrix2_rat = matrix2_data.ratID;
                striosome_tetrode=matrix2_data.tetrodeN;
                if strcmp(matrix2_rat,rat) && strcmp(matrix2_session,session) %&& strcmp(tetrodeN,striosome_tetrode)
                    matrix_indexes = [matrix_indexes;matrix1_index];
                    matrix2_indexes = [matrix2_indexes;matrix2_index];
                end
            end
        end
        matrix_matrix_pairs = [matrix2_indexes,matrix_indexes];
        cd(workingDIR)


        %Now call mat_mat_plot_dynamics.m for each pair 
        %save the created figure into the appropriate folder depending on
        %the figure's slope
        currentIndex=70;
        striosome_bin_time = 1;
        while currentIndex <= height(matrix_matrix_pairs)
%             try
               figure 
               spikes_matrix_1=currentDataBase(matrix_matrix_pairs(currentIndex,1)).trial_spikes;
               spikes_matrix_2=currentDataBase(matrix_matrix_pairs(currentIndex,2)).trial_spikes;
               [given_fig,gof,significance,slope] = mat_mat_plot_dynamics(spikes_matrix_1,spikes_matrix_2,striosome_bin_time);
               

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
                       elseif slope<0
                           cd("Negative Slope");
                       end
                   catch
                      if slope>0
                           cd("Positive Slope");
                       elseif slope<0
                           cd("Negative Slope");
                      end
                    
                   end 
%                pause(20)
                   saveas(given_fig,thename)
                   disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex)));
                   currentIndex=currentIndex+1; 
                   close(given_fig)
                   cd(currentDir)
                   

    
        
        end
        disp(strcat("Finished ",string(uniqueTaskType(currentTaskType)),...
            " ",string(uniqueConcentrations(currentConcentration)),...
            ". It had ", string(height(matrix_matrix_pairs)), " Pairs."))
    end
end


