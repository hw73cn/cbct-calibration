classdef Plane < handle
	%PLANE A class of plane
	%   To descibe a plane's origin and normal.

	properties (GetAccess = public, SetAccess = private, SetObservable)
		Ori = zeros(3, 1);
		
		Ang = zeros(1, 3);
		Rot = eye(3);
		
		Scl = ones(1, 3);
	end

	methods (Access = public)
		function obj = Plane(ori, ang, scl)
			addlistener(obj, 'Ang', 'PostSet', @obj.onAngChange);
			addlistener(obj, 'Scl', 'PostSet', @obj.onSclChange);
			
			obj.Ori = ori;
			obj.Ang = ang;
			obj.Scl(1:2) = scl;
		end
		
		function phtAbs = abs(obj, phtChs)
			phtAbs = [obj.Rot(:, 1:2), obj.Ori] * [phtChs; ones(1, size(phtChs, 2))]; 
		end
				
		function dtcAbs = prj(obj, phtAbs, srcAbs)
			dtcAbs = ones(3, 1) * ((obj.Rot(:, 3)' * (obj.Ori * ones(1, size(phtAbs, 2)) - srcAbs)) ./ (obj.Rot(:, 3)' * (phtAbs - srcAbs))) .* (phtAbs - srcAbs) + srcAbs;
		end
		
		function phtChs = chs(obj, phtAbs)
			phtChs = diag([1, 1, 0]) * ([obj.Rot(:, 1:2), obj.Ori] \ phtAbs);
		end
	end

	methods (Access = private)
		function onAngChange(obj, ~, ~)
			r = Plane.rot(obj.Ang(1), obj.Ang(2), obj.Ang(3));
			obj.Rot = r * diag(obj.Scl);
		end
		
		function onSclChange(obj, metaProp, eventData)
			obj.Scl(3) = obj.Scl(1) * obj.Scl(2);
			obj.onAngChange(metaProp, eventData);
		end
	end

	methods (Access = public, Static)
		function r = rot(pitch, roll, yaw)
			r = roty(roll) * rotx(pitch) * rotz(yaw);
		end
		
		function phtChs = prjChs(obj, dtc, dtcChs)
			dtcAbs = dtc.abs(dtcChs);
			phtAbs = obj.prjAbs(dtcAbs);
			phtChs = obj.chs(phtAbs);
		end
	end
		
end

