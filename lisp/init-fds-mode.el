;; fds-mode.el -- A syntax heightlight mode for data file of FDS(Fire Dynamics Simulator).

;; Copyright (C) 2007,2008 foolstone

;; Author: foolstone <foolstone@gmail.com>
;; Keywords: fds 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Commentary:
;;
;; This file provides a major mode for editing .fds files.
;; It offers syntax highlighting.
;;
;; To use it, put the fds-mode.el file in your load-path, usually you will
;; put the following line in your .emacs 
;; (setq load-path 
;;       (append load-path (list "/your-load-path")))
;;
;; (require 'fds-mode)
;; 
;;
;; Bond a key to function fds-setup-and-preview to preview your model at anytime
;; when you are writing code. For example:
;;     (define-key fds-mode-map "\C-c\C-p" 'fds-setup-and-preview)
;;
;; TODO:
;; - Add some quantity keywords

(defvar fds-mode-hook nil)
(defvar fds-mode-map
  (let ((fds-mode-map (make-keymap)))
    (define-key fds-mode-map "\C-c\C-p" 'fds-setup-and-preview)
    (define-key fds-mode-map "\C-c\C-f" 'fds-count-cells)
    fds-mode-map)
  "Keymap for FDS major mode")
(add-to-list 'auto-mode-alist '("\\.fds\\'" . fds-mode))

(defun fds-count-cells()
  "Calculate number of cells in current MESH line. Note that &MESH line must be a single line"
  (interactive)
  (beginning-of-line)
  (if (looking-at "&.*IJK=.*?\\([0-9]+\\).*?,.*?\\([0-9]+\\).*?,.*?\\([0-9]+\\).*?")
      (or
       (end-of-line)
       (let ((pos (point))
	     (X (string-to-number (match-string 1)))
	     (Y (string-to-number (match-string 2)))
	     (Z (string-to-number (match-string 3)))
	     )
	 (search-backward "/")
	 (forward-char 1)
	 (delete-char (- pos (point)))
	 (insert
	  (format "Cells: %s"
		  (* X Y Z)
		  )
	  )
	 )
       )))

;;C:\ProgramData\Oracle\Java\javapath;%INTEL_DEV_REDIST%redist\ia32\mpirt;%INTEL_DEV_REDIST%redist\ia32\compiler;C:\Program Files\Microsoft HPC Pack 2008 R2\Bin\;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\Program Files\SafeNet\Authentication\SAC\x64;C:\Program Files\SafeNet\Authentication\SAC\x32;c:\Program Files\FDS\FDS6\bin;c:\Program Files\FDS\shortcuts;D:\yy\Android_Dev\sdk\platform-tools;C:\Program Files\Dell\SysMgt\shared\bin;D:\yy\texlive\bin\win32\

(defun fds-setup-and-preview()
  "setup fds and preview with smokeview"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "T_END.*?=.*?[0-9]+.*?/" "T_END=0.0/")
    (save-buffer)
    (goto-char (point-min))
    
    (re-search-forward "\\(CHID\\|chid\\)=\\('\\|\"\\)\\(.*?\\)\\(\"\\|'\\),*")
    (and
     (shell-command (format "fds \"%s\"" (buffer-file-name)) nil nil)
     (shell-command (format "smokeview %s.smv" (match-string-no-properties 3 nil)) "fds-output" nil)
     )))

(defconst fds-keywords-re
  (concat
   "&"
  (regexp-opt '("obst" "vent" "hole" "grid" "pdim" "mesh" "head" "misc" "dump" "zone" "matl" "surf" "reac" "devc" "ctrl" "slcf" "isof" "bndf" "thcp" "tail" "init" "part" "prop" "prof" "radi" "spec" "time" "trnx" "trny" "trnz" "clip" "ramp" "tabl" "evss" "door" "exit" "corr" "entr" "evho" "evac" " pers" "evss" "strs") 'words)
))


(defconst fds-variables-re
  (concat
   (regexp-opt '("evacuation" "evac_humans" "evac_z_offset" "evacuation_drill" "evacuation_mc_mode" "no_evacuation" "human_smoke_height" "quantity" "delay" "function_type" "id" "initial_state" "input_id" "latch" "n" "on_bound" "ramp_id" "setpoint" "bypass_flowrate" "ctrl_id" "depth" "flowrate" "ior" "orientation" "prop_id" "rotation" "trip_direction" "xb" "xyz" "column_dump_limit" "dt_bndf" "dt_devc" "dt_hrr" "dt_isof" "dt_mass" "dt_part" "dt_pl3d" "dt_prof" "dt_restart" "dt_slcf" "maximum_droplets" "nframes" "plot3d_quantity" "render_file" "smoke3d" "mass_file" "write_xyz" "chid" "title" "color" "rgb" "transparency" "density" "mass_fraction" "temperature" "value" "a" "absorption_coefficient" "conductivity" "conductivity_ramp" "emissivity" "heat_of_combustion" "heat_of_reaction" "ignition_temerature" "n_reactions" "n_s" "n_t" "nu_fuel" "nu_residue" "nu_water" "reference_rate" "reference_temperature" "specific_heat" "specific_heat_ramp" "cylindrical" "ijk" "synchronize" "background_species" "baroclinic" "cfl_max" "cfl_min" "csmag" "dns" "gvec" "humidity" "isothermal" "pr" "p_inf" "porous_floor" "radiation" "restart" "restart_chid" "sc" "suppression" "surf_default" "texture_origin" "tmpa" "u0" "v0" "w0" "vn_max" "vn_min" "boiling_temperature" "allow_vent" "bndf_face" "bndf_obst" "outline" "permit_hole" "removable" "sawtooth" "surf_ids" "surf_id6" "thicken" "texture_origin" "surf_id" "age" "diameter" "droplets_per_second" "dt_insert" "fuel" "gamma_d" "heat_of_vaporization" "horizontal_velocity" "initial_temperature" "massless" "mass_per_volume" "melting_temperature" "number_initial_droplets" "sampling_factor" "spec_id" "static" "vaporization_temperature" "vertical_velocity" "activation_temperature" "activation_obscuration" "alpha_c" "alpha_e" "beta_c" "beta_e" "bead_diameter" "bead_emissivity" "c_factor" "characteristic_velocity" "flow_ramp" "flow_tao" "gauge_temperature" "initial_temperaure" "k_factor" "length" "offset" "operating_pressure" "rti" "spray_angle" "spray_pattern_table" "smokeview_id" "angle_increament" "ch4_bands" "kappa0" "nmieang" "number_radiation_angles" "path" "radiative_fraction" "radtmp" "time_step_increment" "wide_band_model" "f" "t" "bof" "c" "co_yield" "critical_flame_temperature" "epumo2" "h" "h2_yield" "ideal" "mass_extinction_coefficient" "maximum_visibility" "mw_other" "n" "n_s" "nu" "o" "other" "odidizer" "soot_yield" "soot_h_fraction" "visibility_factor" "x_o2_ll" "y_f_inlet" "mb" "mesh_number" "pbx" "pby" "pbz" "vector" "absorbing" "conductivty" "diffusivity" "epsilonklj" "mass_fraction_o" "sigmalj" "viscosity" "twfin" "e" "devc_id" "matl_id" "prop_id" "fyi" "leak_area" "thickness" "hrrpua" "tau_q" "t_begin" "t_end" "t_twfin" "wall_increment" "spread_rate" "tmp_exterior" "residue" "threshold_temperature" "volume_flux" "porous") 'words)
   "[ \\t()0-9]*=")
)


;;syntax highlighting using keywords  
(defconst fds-font-lock-keywords-1
  (list
   (list fds-keywords-re '(1 font-lock-builtin-face))
   (list fds-variables-re '(1 font-lock-variable-name-face))
   '("\\<\\(\\([-0-9]*\\.*[0-9]*\\)\\|\\.\\(TRUE\\|FALSE\\)\\.\\)\\>" (1 font-lock-constant-face))
  ))


;;  (defvar fds-font-lock-keywords-2
;;    (append fds-font-lock-keywords-1
;;  	  (list '("\\(surf_id\\|e\\)"  (1 font-lock-variable-name-face)))))



(defvar fds-font-lock-keywords fds-font-lock-keywords-1
  "Default highlighting expressions for FDS mode")

(defvar fds-tab-width 6)


(defun fds-indent-line()
  "Indent current line as FDS data"
  (interactive)
  (beginning-of-line)
  (if (bobp) (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      (if (looking-at "^[ \t]*.*/")
	  (progn
	    (save-excursion
	      (forward-line -1)
	      (setq cur-indent (- (current-indentation) fds-tab-width)))
	    (if (< cur-indent 0)
		(setq cur-indent 0)))
	(save-excursion
	  (while not-indented
	    (forward-line -1)
	    (if (looking-at "^[ \t]*.*/")
		(progn
		  (setq cur-indent (current-indentation))
		  (setq not-indented nil))
	      (if (looking-at "^[ \t]*&")
		  (progn
		    (setq cur-indent (+ (current-indentation) fds-tab-width))
		    (setq not-indented nil))
		(if (bobp)
		    (setq not-indented nil)))))))
      (if cur-indent
	  (indent-line-to cur-indent)
	(indent-line-to 0)))));If we didn't see an indentation hint,then allow no indentation

(defvar fds-mode-syntax-table
  (let ((fds-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" fds-mode-syntax-table)
    (modify-syntax-entry ?& "(" fds-mode-syntax-table)
    (modify-syntax-entry ?/ ")" fds-mode-syntax-table)
    (modify-syntax-entry ?= "." fds-mode-syntax-table)
    (modify-syntax-entry ?' "\"" fds-mode-syntax-table)
    (modify-syntax-entry ?. "w" fds-mode-syntax-table)
    (modify-syntax-entry ?- "w" fds-mode-syntax-table)
    (modify-syntax-entry ?\( "(" fds-mode-syntax-table)
    (modify-syntax-entry ?\) ")" fds-mode-syntax-table)
    fds-mode-syntax-table)
  "Syntax table for fds-mode")

(defun fds-mode()
  "Major mode for editing FDS data files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table fds-mode-syntax-table)
  (use-local-map fds-mode-map)
  (set (make-local-variable 'abbrev-all-caps) t)
  (set (make-local-variable 'font-lock-defaults) '(fds-font-lock-keywords nil t))
  (set (make-local-variable 'indent-line-function) 'fds-indent-line)
  (setq major-mode 'fds-mode)
  (setq mode-name "FDS")
  (run-hooks 'fds-mode-hook))
(provide 'init-fds-mode)

	      
