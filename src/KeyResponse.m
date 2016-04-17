
function output = KeyResponse(type, valid_indices, varargin)
% type is the type of response device (keyboard or force transducer)
% valid_indices are determined from the tgt file, and are used to specify
%     which of the keys or force transducers should be used
% varargin are additional constants set in the Constants.m file, or alternatively,
%     are passed manually. (How to specify the order though??)

if nargin < 2 % check for too few inputs
    error('Too few inputs to KeyResponse().');
end

opts = struct('firstparameter', 1, 'secondparameter', magic(3));
opts = CheckInputs(opts, varargin{:}); % this pattern ought to be pretty constant





end