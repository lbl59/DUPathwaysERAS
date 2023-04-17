function y = generate_sample(sample_no, output_directory, historical_data_dir)
% graphics_toolkit('gnuplot')

inflow_dir = historical_data_dir; %[output_directory 'historical'];
inflow_files = {'claytonGageInflow', 'crabtreeCreekInflow', 'updatedFallsLakeInflow', 'updatedJordanLakeInflow', 'updatedLakeWBInflow', 'updatedLillingtonInflow', 'updatedLittleRiverInflow', 'updatedLittleRiverRaleighInflow', 'updatedMichieInflow', 'updatedOWASAInflow'};               
evaporation_files = {'', '', 'fallsLakeEvap', 'updatedEvap', 'lakeWheelerBensonEvap', '', '', 'fallsLakeEvap', '', 'updatedEvap'};

%num_realizations = 500; % Sept 2020: changed for 500 realization borg runs
num_realizations = 1000; % Aug 2021: back to 1000 for Dave re-eval paper (set to 2,000 for reevaluation)
%num_realizations = 10; % for cube testing
%num_realizations = 5000;
num_years = 48;
num_samples = 1;
em = zeros(1, length(inflow_files));
%rdm_all = load('rdm_inflows_test_problem_reeval.csv');
rdm_all = load('RDM_LHS_inflows_DU_reeval.csv'); % new file of sinusoidal factors
%for Aug 2021(uncomment for reevaluation)
%rdm= load('RDM_LHS_inflows_opt.csv'); % for optimization
%rdm_all = load('./rdm_water_sources_test_problem_reeval.csv');
rdm = repmat(rdm_all(sample_no + 1, :), num_realizations, 1); % 

%rdm(:, 1) = 0.
%rdm(:, 2) = 1.
%rdm(:, 3) = 1.

for k=1:length(inflow_files)
    Qh{k} = load([inflow_dir inflow_files{k} '.csv']);
    output_inflow{k} = zeros(num_realizations, num_years*52);
    % size(evaporation_files(k))
    if ~strcmp(evaporation_files(k), '')
        E = -load([inflow_dir evaporation_files{k} '.csv']);
	em(k) = min(min(E))-1e-6;
	Eh{k} = E - em(k);
   else
        Eh{k} = zeros(2, 1);
    end
    output_evap{k} = zeros(num_realizations, num_years*52);  
end

%t1 = time(); 
% generate realizations
for r=1:num_realizations
    % r
    nQ_historical = length(Qh{1}(:,1));
    nQ = nQ_historical * 100;
    Random_Matrix = randi(nQ, num_years+1, 52);
    [Qs, Es] = stress_dynamic(Random_Matrix, Qh, Eh, num_years, rdm(r, :)); % or call stress(Qh, num_years, p, n)
    % [Qs, Es] = stress_dynamic(Random_Matrix, Qh, Eh, num_years, rdm(47, :)); % or call stress(Qh, num_years, p, n)

    for k=1:length(inflow_files)
        output_inflow{k}(r,:) = reshape(Qs{k}',1,[]);
        output_evap{k}(r,:) = reshape(Es{k}',1,[]);
    end
    % printf('Realization %d finished\n', r)
end

%time() - t1
for k=1:length(inflow_files)
    inflows_file = [output_directory inflow_files{k} '.csv'];
    evaps_file = [output_directory 'evaporation' '/' inflow_files{k} '.csv']; % SUPPOSED TO BE INFLOW_FILES HERE
    dlmwrite([inflows_file], output_inflow{k});
    if (output_evap{k}(1,1) ~= -100)
        dlmwrite([evaps_file], -(output_evap{k} + em(k)));
    end
%    dlmwrite(['inflows-synthetic-matlab/' inflow_files{k} '.csv'], output_inflow{k});
%    if (output_evap{k}(1,1) ~= -100)
%        dlmwrite(['inflows-synthetic-matlab/' inflow_files{k} '.csv'], -(output_evap{k} + em(k)));
%    end
end
