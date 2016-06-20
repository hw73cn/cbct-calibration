% This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
%
% https://github.com/Rholais/cbct-calibration
%
% Copyright 2016 Haocheng Li and contributors
%
% License:  Standard 3-clause BSD; see "LICENSE" for full license terms
%           and contributor agreement.

classdef Cbct < handle
	%CBCT Cone beam computed tomography
	%   Cone beam computed tomography (or CBCT, also referred to as C-arm 
	%   CT, cone beam volume CT, or flat panel CT) is a medical imaging 
	%   technique consisting of X-ray computed tomography where the X-rays 
	%   are divergent, forming a cone.
	%	生成\textmu CT投影的特征数组与标签数组部分的主体

	properties (GetAccess = public, SetAccess = private)
		%	\textmu CT的X射线源坐标
		%	一个$3 \times 1$双精度数组，初始化为零
		Src = zeros(3, 1);
		%	待投影的物体或器官
		%	`Pht`类型的句柄
		Pht;
		%	X射线平面探测器
		%	`Plane`类型的句柄
		Dtc;
	end

	methods (Access = public)
		function obj = Cbct(src, pht, dtc)
			obj.Src = src;
			obj.Pht = pht;
			obj.Dtc = dtc;
		end
		
		%	将X射线源坐标系的坐标转化为实际探测器坐标系下的坐标
		function dtcChs = prj(obj, gantry)
			srcArr = obj.Src * ones(1, obj.Pht.CpN * obj.Pht.BbN);
			bbA = roty(gantry) * obj.Pht.BbA;
			dtcAbs = obj.Dtc.prj(bbA, srcArr);
			dtcChs = obj.Dtc.chs(dtcAbs);
		end
	end

end
