classdef Cbct < handle
	%CBCT Cone beam computed tomography
	%   Cone beam computed tomography (or CBCT, also referred to as C-arm 
	%   CT, cone beam volume CT, or flat panel CT) is a medical imaging 
	%   technique consisting of X-ray computed tomography where the X-rays 
	%   are divergent, forming a cone.

	properties (GetAccess = public, SetAccess = private)
		Src = zeros(3, 1);
		Pht;
		Dtc;
	end

	methods (Access = public)
		function obj = Cbct(src, pht, dtc)
			obj.Src = src;
			obj.Pht = pht;
			obj.Dtc = dtc;
		end
		
		function dtcChs = prj(obj, gantry)
			srcArr = obj.Src * ones(1, obj.Pht.CpN * obj.Pht.BbN);
			bbA = roty(gantry) * obj.Pht.BbA;
			dtcAbs = obj.Dtc.prj(bbA, srcArr);
			dtcChs = obj.Dtc.chs(dtcAbs);
		end
	end

end
