function param_vc_Rs_comp_int_t_test(ifplot)
  
% param_vc_Rs_comp_int_t_test - Unit test.
%
% Usage:
%   param_vc_Rs_comp_int_t_test(ifplot)
%
% Parameters:
%   ifplot: If 1, produce plots.
%
% Returns:
%
% Description:
%   Visually compare prediction and correction results. No equality
% tests available. Uses the xunit framework by Steve Eddins downloaded
% from Mathworks File Exchange.
%
% See also: xunit
%
% $Id: param_Re_Ce_cap_leak_act_int_t_test.m 168 2010-10-04 19:02:23Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2015/05/12

% TODO: add some more equality tests for latter prediction and correction.

ifplot = defaultValue('ifplot', 0);

% compare ReCe and Rs comp
capleakReCe_f = ...
    param_Re_Ce_cap_leak_act_int_t(...
      struct('Re', 28, 'Ce', 2e-4, 'gL', 3.2e-3, ... % Ce=2e-4 OR 4e-3
             'EL', -88, 'Cm', .018, 'delay', 0, 'offset', 0), ... % EL=-70
      ['cap, leak, Re and Ce']);

% set prediction and correction to 0 => should be identical to above
ampReCe_f = ...
    param_vc_Rs_comp_int_t(...
      struct('Rscomp', 28, 'Re', 28, 'pred', 0, 'corr', 0, ...
             'Ce', 2e-4, 'gL', 3.2e-3, ... 
             'EL', -88, 'Ccomp', .018, 'Cm', .018, 'delay', 0, 'offset', 0), ... 
      ['VC Rscomp no pred/corr'], ...
        struct('wholeCell', 0));


% make a perfect voltage clamp data (could have used makeIdealClampV)
pre_v = -70;
pulse_v = -90:10:-50;
post_v = -70;
dt = 0.025; % [ms]
pre_t = round(10/dt) + 1; % +1 for neuron
pulse_t = round(100/dt);
post_t = round(10/dt);

a_p_clamp = ...
    voltage_clamp([ repmat(0, pre_t + pulse_t + post_t, length(pulse_v))], ...
                  [ repmat(pre_v, pre_t, length(pulse_v)); ...
                    repmat(pulse_v, pulse_t, 1); ...
                    repmat(post_v, post_t, length(pulse_v)) ], ...
                  dt*1e-3, 1e-9, 1e-3, 'Ideal voltage clamp');

% simulate
sim_old_vc = ...
    simModel(a_p_clamp, capleakReCe_f, ...
             struct('levels', 1:5, 'updateVm', 1));
sim_new_vc = ...
    simModel(a_p_clamp, ampReCe_f, ...
             struct('levels', 1:5, 'updateVm', 1));

if ifplot
  % plot all internal variables from 1st trace
  plotFigure(plot_stack({...
      plot_abstract({...
          [sim_new_vc.props.intOuts.I_prep(:, 1), ...
           sim_new_vc.props.intOuts.I_w(:, 1)]}, {'dt', 'nA'}, ...
                    'internals - amp no whole cell', ...
                    {'I_{prep}', 'I_{w}'}, 'plot'), ...
      plot_abstract({...
          [sim_new_vc.props.intOuts.Vp(:, 1), ...
           sim_new_vc.props.intOuts.Vm(:, 1), ...
           sim_new_vc.props.intOuts.Vw(:, 1)]}, {}, '', ...
                    {'V_{p}', 'V_{m}', 'V_{w}'}, 'plot')}));  
  
  % TODO: implement stacking with noCombine
  plotFigure(plot_superpose({...
      plot_abstract(sim_old_vc, '', struct('relativeSizes', [2 1], 'label', 'old Re')), ...
      plot_abstract(sim_new_vc, '', struct('relativeSizes', [2 1], ...
                                         'label', 'amp no whole cell'))}, ...
                            {}, '', struct));
end

% compare total current w/o whole cell compen
assertElementsAlmostEqual(sim_old_vc.i.data, ...
                          sim_new_vc.i.data, 'absolute', 1e-2);

% load neuron files
tr_m90 = ...
    trace('Ic_dt_0.025000ms_dy_1e-9nA_vclamp_-70_to_-90_mV.bin', ...
          0.025e-3,  1e-9, 'neuron sim Ic', ...
          struct('file_type', 'neuron', ...
                 'unit_y', 'A'));

tr_m50 = ...
    trace('Ic_dt_0.025000ms_dy_1e-9nA_vclamp_-70_to_-50_mV.bin', ...
          0.025e-3,  1e-9, 'neuron sim Ic', ...
          struct('file_type', 'neuron', ...
                 'unit_y', 'A'));

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(tr_m90, '', struct('label', 'Neuron sim', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(setLevels(sim_new_vc, 1), '', struct('onlyPlot', 'i', ...
                                                    'label', 'new Re'))}));
  plotFigure(plot_superpose({...
    plot_abstract(tr_m50, '', struct('label', 'Neuron sim', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(setLevels(sim_new_vc, 5), '', struct('onlyPlot', 'i', ...
                                                    'label', 'new Re'))}));
end

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(tr_m90 - get(setLevels(sim_new_vc, 1), 'i'), '', ...
                  struct('label', '\Delta @ -90 mV', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(tr_m50 - get(setLevels(sim_new_vc, 5), 'i'), '', ...
                  struct('onlyPlot', 'i', 'label', '\Delta @ -50 mV'))}));
end

% test if matches
skip_dt = 3/dt; % skip settlement artifact at beginning
assertElementsAlmostEqual(tr_m90.data(skip_dt:end), ...
                          sim_new_vc.i.data(skip_dt:end, 1), 'absolute', 1e-1);

assertElementsAlmostEqual(tr_m50.data(skip_dt:end), ...
                          sim_new_vc.i.data(skip_dt:end, 5), 'absolute', 1e-1);

% turn on whole-cell compensation (w/o prediction or correction)
amp_wholeCell_f = ...
    param_vc_Rs_comp_int_t(...
      struct('Rscomp', 28, 'Re', 28, 'pred', 0, 'corr', 0, ...
             'Ce', 1e-8, 'gL', 3.2e-3, ... 
             'EL', -88, 'Ccomp', .018, 'Cm', .018, 'delay', 0, 'offset', 0), ... 
      ['VC Rscomp no pred/corr']);

sim_wholeCell_vc = ...
    simModel(a_p_clamp, amp_wholeCell_f, ...
             struct('levels', 1:5, 'updateVm', 1));

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(sim_old_vc, '', struct('relativeSizes', [2 1], 'label', 'old Re')), ...
    plot_abstract(sim_wholeCell_vc, '', ...
                  struct('relativeSizes', [2 1], 'label', 'whole cell'))}));
end

% with prediction
amp_pred80_f = ...
    param_vc_Rs_comp_int_t(...
      struct('Rscomp', 28, 'Re', 28, 'pred', 80, 'corr', 0, ...
             'Ce', 1e-8, 'gL', 3.2e-3, ... 
             'EL', -88, 'Ccomp', .018, 'Cm', .018, 'delay', 0, 'offset', 0), ... 
      ['VC Rscomp pred 80']);

sim_pred80_vc = ...
    simModel(a_p_clamp, amp_pred80_f, ...
             struct('levels', 1:5, 'updateVm', 1));

if ifplot
  % plot all internal variables from 1st trace
  trace_num = 5;
  plotFigure(plot_stack({...
      plot_abstract({...
          [sim_pred80_vc.props.intOuts.I_prep(:, trace_num), ...
           sim_pred80_vc.props.intOuts.I_w(:, trace_num)]}, {'dt', 'nA'}, ...
                    'internals - pred 80', ...
                    {'I_{prep}', 'I_{w}'}, 'plot'), ...
      plot_abstract({...
          [sim_pred80_vc.props.intOuts.Vp(:, trace_num), ...
           sim_pred80_vc.props.intOuts.Vm(:, trace_num), ...
           sim_pred80_vc.props.intOuts.Vw(:, trace_num)]}, {}, 'internals', ...
                    {'V_{p}', 'V_{m}', 'V_{w}'}, 'plot')}));  

  plotFigure(plot_superpose({...
    plot_abstract(sim_pred80_vc, '', ...
                  struct('relativeSizes', [2 1], 'label', 'pred 80')), ...
    plot_abstract(sim_wholeCell_vc, '', ...
                  struct('relativeSizes', [2 1], 'label', 'whole cell'))}));
end

% with correction
amp_corr80_f = ...
    param_vc_Rs_comp_int_t(...
      struct('Rscomp', 28, 'Re', 28, 'pred', 80, 'corr', 80, ...
             'Ce', 1e-8, 'gL', 3.2e-3, ... 
             'EL', -88, 'Ccomp', .018, 'Cm', .018, 'delay', 0, 'offset', 0), ... 
      ['VC Rscomp corr 80']);

sim_corr80_vc = ...
    simModel(a_p_clamp, amp_corr80_f, ...
             struct('levels', 1:5, 'updateVm', 1));

if ifplot
  % plot all internal variables from 1st trace
  trace_num = 1;
  plotFigure(plot_stack({...
      plot_abstract({...
          [sim_corr80_vc.props.intOuts.I_prep(:, trace_num), ...
           sim_corr80_vc.props.intOuts.I_w(:, trace_num), ...
           sim_corr80_vc.props.intOuts.I_ion(:, trace_num)]}, ...
                    {'dt', 'nA'}, 'internals - corr 80', ...
                    {'I_{prep}', 'I_{w}', 'I_{ion}'}, 'plot'), ...
      plot_abstract({...
          [sim_corr80_vc.props.intOuts.Vp(:, trace_num), ...
           sim_corr80_vc.props.intOuts.Vm(:, trace_num), ...
           sim_corr80_vc.props.intOuts.Vw(:, trace_num), ...
           sim_corr80_vc.props.intOuts.V_pred(:, trace_num), ...
           sim_corr80_vc.props.intOuts.V_corr(:, trace_num)]}, {}, 'internals', ...
                    {'V_{p}', 'V_{m}', 'V_{w}', 'V_{pred}', 'V_{corr}'}, 'plot')}));  

  plotFigure(plot_superpose({...
      plot_abstract(sim_pred80_vc, '', ...
                    struct('relativeSizes', [2 1], 'label', 'pred 80')), ...
      plot_abstract(sim_corr80_vc, '', ...
                    struct('relativeSizes', [2 1], 'label', 'corr 80')), ...
      plot_abstract(a_p_clamp, '', ...
                    struct('relativeSizes', [2 1], 'label', 'ideal clamp'))}));
  
end
