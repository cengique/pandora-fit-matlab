%% this script uses Pandora toolbox to do the Rs compensation
% CG 2015/04/01

% need these in the path:
addpath ~/Dropbox/Na_fits_Panuccio/MATLAB
addpath ~/Dropbox/Na_fits_Panuccio/cengiz/pandora/classes
addpath ~/Dropbox/Na_fits_Panuccio/cengiz/pandora/functions
addpath ~/Dropbox/Na_fits_Panuccio/cengiz/param_fitter


%% Estimate passive parameters of one VC protocol from example K
%% channel data

wt1_cap_1_vc = ...
    abf2voltage_clamp([ 'example_data/10o21000.abf' ]);

results_wt1_cap_tr1 = ...
    getResultsPassiveReCeElec(data_L1_passive(wt1_cap_1_vc), ...
                              struct('maxStepDur', 20));

% should find these:
% $$$ resnorm: 0.02194, ssenorm: 0.0033212
% $$$     'Param'        'Value'          'Diff'           '95% rel. conf.' 
% $$$     'Vm_Re'        [   256.7631]    [    20.8607]    '+/- 28.9648'    
% $$$     'Vm_Ce'        [ 3.4655e-04]    [ 8.5608e-06]    '+/- 5.06822e-05'
% $$$     'Vm_Cm'        [     0.0029]    [-8.9946e-05]    '+/- 0.000305847'
% $$$     'Vm_offset'    [-3.4310e-05]    [    -0.0031]    '+/- 0.00155676' 

%% Load Gabriella's files

% Warning: it closes all figures first!
cd ~/Dropbox/Na_fits_Panuccio/NO_Rs_COMP
[t_PN_PULSES,PN_PULSES,PN_PROTOCOL,I_PN_PULSES,ILeak] = ...
    PN(-70, -90, 4);

cd ~/Dropbox/Na_fits_Panuccio/Rs_COMP
[t_PN_PULSES,PN_PULSES,PN_PROTOCOL,I_PN_PULSES,ILeak] = ...
    PN(-70, -90, 4);

% TODO: 
% - create Pandora voltage_clamp object from H5 files using
% Gabriella's scripts


%% Example K current fits

% note: this example is tuned to load multiple ABF files that
% contain different VC protocols, estimate their passive parameters
% and do leak subtraction and averaging across cells

doc_dir_wt2 = 'Kchan/';

% cell 1
wt5_inact_ts = ...
    traceset_L1_passive([0:17], ...
                        struct('passive', [0, 1:3, 4:6, 10:12, 16], ...
                               'holdM90', [1:3], ...
                               'inact_fromM125toM5up30holdM60', [4:6], ...
                               'act_holdM90fromM60to40holdM60', [10:12], ...
                               'act_holdM50fromM60to40holdM60', [7:9], ...
                               'act_hold0fromM60to40holdM60', [13:15]), ...
                        'WT_10o22_aCC_5', ...
                        struct('fileTempl', '10o22%03d.abf', ...
                               'baseDir', ...
                               [ L1_WT_inact_datadir 'WT_inact_aCC_5/' ], ...
                               'docDir', doc_dir_wt2, ...
                               'timeAvg', 10));
% cell 2
wt6_inact_ts = ...
    traceset_L1_passive([18:37], ...
                        struct('passive', [18, 19:21, 22:24, 25:27, 36], ...
                               'holdM90', [19:21], ...
                               'inact_fromM125toM5up30holdM60', [22:24], ...
                               'act_holdM90fromM60to40holdM60', [25:27], ...
                               'act_holdM50fromM60to40holdM60', [28:30], ...
                               'act_hold0fromM60to40holdM60', [33:35]), ...
                        'WT_10o22_aCC_6', ...
                        struct('fileTempl', '10o22%03d.abf', ...
                               'baseDir', ...
                               [ L1_WT_inact_datadir 'WT_inact_aCC_6/' ], ...
                               'docDir', doc_dir_wt2, ...
                               'timeAvg', 10));

% all cells
prots = struct;
prots.averageTracesSave = {...
  'holdM90', 'inact_fromM125toM5up30holdM60', ...
  'act_holdM90fromM60to40holdM60', 'act_holdM50fromM60to40holdM60', ...
  'act_hold0fromM60to40holdM60'};
wt_inact_cells_2 = ...
    cellset_L1({wt5_inact_ts, wt6_inact_ts}, prots, ...
               ['WT inact + 4 act prots v2 cells recorded on 2010/10/22'], ...
               struct('docDir', doc_dir_wt2, 'protZoom', ...
                      struct('holdM90', [120 180 -2e-8 16e-8], ...
                             'inact_fromM125toM5up30holdM60', [535 544 0e-8 10e-8], ...
                             'act_holdM90fromM60to40holdM60', [517 544 -.3e-8 10e-8], ...
                             'act_holdM50fromM60to40holdM60', [517 544 -.3e-8 10e-8], ...
                             'act_hold0fromM60to40holdM60', [517 544 -.3e-8 10e-8])));

save([doc_dir_wt2 filesep properTeXFilename(wt_inact_cells_2.id) ' - cellset.mat'], 'wt_inact_cells_2')

% test cap est
warning on verbose
a_prof = loadItemProfile(wt7_inact_ts, 1)
warning off verbose

[a_db, Cm_avg, plot_doc] = processCapEst(wt6_inact_ts);

% cap est across cells
[a_db, a_stats_db, Cm_avg_db] = ...
    processCapEst(wt_inact_cells_2, struct('closeFigs', 1));

% test averaging within cell's traceset
[avg_vc sd_vc tex_file] = averageTracesSave(wt3_inact_ts, 'holdM90');

% averaging across cells

% test
prot_props = struct;
prot_props.protNames = {'inact_fromM125toM5up30holdM60'};
[tex_file] = averageTracesSave(wt_inact_cells_2, ...
                               prot_props);

% all
[tex_file] = averageTracesSave(wt_inact_cells_2);
