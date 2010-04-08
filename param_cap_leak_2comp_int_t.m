function a_pf = param_cap_leak_2comp_int_t(param_init_vals, id, props) 
  
% param_cap_leak_2comp_int_t - Membrane capacitance and leak in ball-and-stick model integrated over time.
%
% Usage:
%   a_pf = param_cap_leak_2comp_int_t(param_init_vals, id, props)
%
% Parameters:
%   param_init_vals: Array or structure with initial values for leak
%     conductance, gL [uS]; leak reversal, EL [mV]; cell capacitance, Cm
%     [nF], an axial resistance, Ra [MOhm], a second compartment
%     capacitance, Ca [nF], and a delay [ms].
%   id: An identifying string for this function.
%   props: A structure with any optional properties.
% 	   (Rest passed to param_func)
%		
% Returns a structure object with the following fields:
%	param_mult: Holds the inf and tau functions.
%
% Description:
%   Defines a function f(a_pf, {v, dt}) where v is an array of voltage
% values [mV] changing with dt time steps [ms].
%
% See also: param_func, param_cap_leak_int_t, param_Rs_cap_leak_int_t
%
% Example:
% >> f_capleak = ...
%    param_cap_leak_2comp_int_t(struct('gL', 3, 'EL', -80, 'Cm', 1e-2, ...
%				'Ra', 1, 'Ca', 1e-1, 'delay', .1), ...
%                               ['Ca chan 3rd instar cap leak']);
%
% $Id$
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/03/19
  
% TODO:
  
  if ~ exist('props', 'var')
    props = struct;
  end

  if ~ exist('id', 'var')
    id = '';
  end

  param_names_ordered = {'gL', 'EL', 'Cm', 'Ra', 'gLa', 'Ca', 'delay'};
  if ~ isstruct(param_init_vals)
    param_init_vals = ...
        cell2struct(num2cell(param_init_vals(:)'), ...
                    param_names_ordered, 2);
  else
    % check if field names match to what this object needs
    if length(intersect(fieldnames(param_init_vals), ...
                        param_names_ordered)) ~= length(param_names_ordered)
      disp('Provided params:')
      disp(param_init_vals)
      disp('Required param names:')
      disp(param_names_ordered)
      error([ 'Parameters supplied mismatch! See above.' ]);
    end
    % make sure they're ordered consistently to match the range description
    param_init_vals = ...
        orderfields(param_init_vals, param_names_ordered);
  end
  
  % physiologic parameter ranges
  param_ranges = ...
      [ eps -200 eps eps eps eps 0;...
        1e3 100 1e3  1e3 1e3 1e3 10];
  
  a_pf = ...
      param_func(...
        {'time [ms]', 'I_{cap+leak} 2 \tau{}s [nA]'}, ...
        param_init_vals, [], ...
        @cap_leak_int, id, ...
        mergeStructs(props, struct('paramRanges', param_ranges)));
  
  function [Ic, dIdt] = cap_leak_int(p, v_dt)
    Vc = v_dt{1};
    dt = v_dt{2};
    
    % do the delay as float and interpolate Vc so that the fitting
    % algorithm can move it around
    delay_dt = p.delay/dt;
    delay_dt_int = floor(delay_dt);
    delay_dt_frac = delay_dt - delay_dt_int;

    % make a new vector for delayed voltage
    Vc_delay = ...
        [ repmat(Vc(1, :), delay_dt_int + 1, 1); ...
          Vc(2:(end-delay_dt_int), :) - ...
          delay_dt_frac * ...
          diff(Vc(1:(end-delay_dt_int), :)) ];

    % first estimate of 2nd compartment voltage
    [t_tmp, Va] = ...
        ode15s(@(t, Va) ...
               (- (Va - Vc_delay(round(t/dt) + 1, :)') ...
                / p.Ra - p.gLa * (Va - p.EL) ) / p.Ca, ...
               (0:(size(Vc, 1) - 1))*dt, Vc(1, :));
    Ic = ...
        p.Cm * [diff(Vc_delay); zeros(1, size(Vc, 2))] / dt + ...
        (Vc_delay - p.EL) * p.gL - (Va - Vc_delay) / p.Ra;
    dIdt = NaN;
  end

end

