%% load databases
[dbs,twdbs] = loadData;

%% get statistics
clc;
by_task_type = 1;
by_conc = 0;
by_database = 0;
for i=1:length(twdbs)
    current_db = twdbs{i};
    current_db = struct2table(current_db);
    session_and_rat_id = strcat(current_db.sessionID,current_db.ratID);
    unique_session_and_rat_id = unique(session_and_rat_id);
    disp(dbs{i})
    if by_database
        disp(strcat(dbs{i}, " Statistics"));
        disp(strcat("Number of sessions:",string(size(unique_session_and_rat_id,1))));
        disp(strcat("Number of animals:",string(size(unique(current_db.ratID),1))));
        disp(strcat("Number of cells:",string(size(current_db,1))));

    end
    unique_task_types = unique(current_db.taskType);

    for j=1:length(unique_task_types)
        current_task_type = unique_task_types{j};
        disp(strcat(current_task_type));
        table_of_only_current_task_type = current_db(strcmpi(current_db.taskType,current_task_type),:);
        number_of_sessions_by_task_type = strcat(table_of_only_current_task_type.sessionID,table_of_only_current_task_type.ratID);
        number_of_sessions_by_task_type = string(size(unique(number_of_sessions_by_task_type),1));
        if by_task_type
            disp(strcat("Number of sessions:",number_of_sessions_by_task_type));
            disp(strcat("Number of animals:",string(size(unique(table_of_only_current_task_type.ratID),1))));
            disp(strcat("Number of cells:",string(height(table_of_only_current_task_type))));
        end
        unique_concentrations = unique(table_of_only_current_task_type.conc);
        unique_concentrations(isnan(unique_concentrations)) = [];

        for k=1:length(unique_concentrations)
            current_concentration = unique_concentrations(k);
            
            table_of_only_current_concentration = table_of_only_current_task_type(table_of_only_current_task_type.conc==current_concentration,:);
            number_of_sessions_by_tt_and_conc = strcat(table_of_only_current_concentration.sessionID,table_of_only_current_concentration.ratID);
            number_of_sessions_by_tt_and_conc = string(size(unique(number_of_sessions_by_tt_and_conc),1));
            if by_conc
                disp(strcat(current_task_type," ",string(current_concentration),"_______________ "));
                disp(strcat("Number of sessions:",number_of_sessions_by_tt_and_conc));
                disp(strcat("Number of animals:",string(size(unique(table_of_only_current_concentration.ratID),1))));
                disp(strcat("Number of cells:",string(height(table_of_only_current_concentration))));
            end
        end
    end

    disp("/////////////////////////////////")
end