%% load databases
[dbs,twdbs] = loadData;
%% run cross correlation
cd('C:\Users\ldd77\OneDrive\Documents\Striosome-Matrix-Analysis\Fig7A_triplet-example')
clc;
namesOfDatabases = ["Control","Stress1","Stress2"];
list_of_which_tasks_should_be_split = ["TR"];
where_to_split = 50;


for currentDB = 1:1.5%length(twdbs) %cycle through the databases (AKA the Outer Loop in future comments)
    currentDatabase = twdbs{currentDB}; %get the database
    t = struct2table(currentDatabase); %turn it into a table for reading
    uniqueTaskType = unique(t.taskType); %get the unique task types within the current databaser

    disp(strcat("Database:", string(namesOfDatabases(currentDB))));
    for i =1:length(uniqueTaskType)
        if ismember(string(uniqueTaskType(i)), list_of_which_tasks_should_be_split)
            the_OG_task_type = string(uniqueTaskType(i));
            uniqueTaskType{i} = strcat(the_OG_task_type, " 0 to ",num2str(where_to_split-1));
            uniqueTaskType{end+1} = strcat(the_OG_task_type," ", num2str(where_to_split)," to 100");
        end
    end


    % name_of_database_folder = strcat(namesOfDatabases(currentDB), " split with filter updated michael for EQR and rev cb, neg inf micheal for everything else"); %get name of current database
    % mkdir(name_of_database_folder) %make a directory with the same name as the current database
    % og_dir = cd(name_of_database_folder); %movve into the folder with the name of the current database
    % path_of_database_folder = cd(og_dir);
    % cd(path_of_database_folder);
    number_of_task_type_loops_that_will_be_done = length(uniqueTaskType) + length(list_of_which_tasks_should_be_split); %this is a dynamic way to tell how many loops to do in the case of wanting to split current task type
    uniqueTaskType = {["TR 0 to 49"],["TR 50 to 100"]};
    for ttCounter = 1:length(uniqueTaskType) %cycle through all the taks types in the current database


        currentTaskType = uniqueTaskType{ttCounter};%get the task type
        disp(strcat("Current Task Type:", currentTaskType)) %display the task type


        name_of_task_type_folder = currentTaskType; %get name of the current task type
        % mkdir(name_of_task_type_folder)
        % cd(name_of_task_type_folder) %move into the folder with the name of the current task type
        % path_of_task_type_folder = cd(path_of_database_folder);
        % cd(path_of_task_type_folder);

        if contains(string(currentTaskType),"to") && ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            cd('C:\Users\ldd77\OneDrive\Documents\Striosome-Matrix-Analysis\Fig7A_triplet-example')
            the_current_task_type_split = split(string(currentTaskType)," ");
            the_min = str2double(the_current_task_type_split{2});
            the_max = str2double(the_current_task_type_split{4});
            the_task_type = the_current_task_type_split{1};
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids_split(twdbs,the_task_type,[-Inf,-Inf,-Inf,-Inf,1],[the_min,the_max]);

        elseif ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            cd('C:\Users\ldd77\OneDrive\Documents\Striosome-Matrix-Analysis\Fig7A_triplet-example');
            [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],nan);
        end

        % cd(path_of_task_type_folder) %move back to the task type folder
        if strcmpi(string(currentTaskType),"eqr") || strcmpi(string(currentTaskType),'rev cb')
            cd('C:\Users\ldd77\OneDrive\Documents\Striosome-Matrix-Analysis\Fig7A_triplet-example');
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],nan);
            disp("hello");
        end


    end
end

