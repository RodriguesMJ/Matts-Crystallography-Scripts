;; Taken from https://strucbio.biologie.uni-konstanz.de/ccp4wiki/index.php/Partial-occupancy-navigation.scm
;; 
(define (low-occ-gui imol occ-threshold)
  (interesting-residues-gui 
   imol
   "Residues with low occupancy..."
   (residues-matching-criteria
    imol 
    (lambda (chain-id res-no ins-code res-serial-no)
      
      (let ((atom-ls (residue-info imol chain-id res-no ins-code)))
	
	;; return #f if there are no atoms with alt-confs, else return
	;; a list of the residue's spec (chain-id resno ins-code)
	;; 
	(let g ((atom-ls atom-ls))
	  (cond 
	   ((null? atom-ls) #f)
	   (else 
	    (let* ((atom (car atom-ls))
		   (occ (car (car (cdr atom)))))
	      (if (< occ occ-threshold)
		  #t
		  (g (cdr atom-ls))))))))))))
  

(let ((menu (coot-menubar-menu "Extras")))
  (add-simple-coot-menu-menuitem
   menu "Residues with low occupancy..."
   (lambda ()
     (generic-chooser-and-entry 
      "Molecule for low occupancy analysis:"
      "Occupancy threshold"
      "0.9"
      (lambda (imol text)
	(let ((n (string->number text)))
	  (if (number? n)
	      (low-occ-gui imol n))))))))
