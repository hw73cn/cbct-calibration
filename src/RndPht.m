% This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
%
% https://github.com/Rholais/cbct-calibration
%
% Copyright 2016 Haocheng Li and contributors
%
% License:  Standard 3-clause BSD; see "LICENSE" for full license terms
%           and contributor agreement.

classdef RndPht < Pht
	%RNDPHT The random calibration phantom
	%   The calibration phantom consists of a random arrangement of a set 
	%   of steel ball bearings (BBs) embedded in a cubic plastic phantom.

	properties (GetAccess = public, SetAccess = private)
	end

	methods (Access = public)
		function obj = RndPht(cpD, bbN, bbD)
			num = 1000;
			rnd = rand(3, bbN, num);
			knn = zeros(num, 1);
			for i = 1:num
				[~, D] = knnsearch(rnd(:, :, i)', rnd(:, :, i)', 'K', 2);
				knn(i) = min(D(:, 2));
			end
			[~, I] = max(knn);
			bbA = - cpD / 2 + cpD * rnd(:, :, I);
			obj@Pht(1, cpD, bbN, bbD, 0, bbA);
		end
	end

end
