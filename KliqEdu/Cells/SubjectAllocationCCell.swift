//
//  SubjectAllocationCCell.swift
//  KliqEdu
//

import UIKit

class SubjectAllocationCCell: UICollectionViewCell {

    //MARK: Outlets

    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var classTeacherImgView: UIImageView!

    func configureCellWith(allocation: SubjectAllocation, isClassTeacherClass: Bool) {
        subjectLbl.text = allocation.subject
        gradeLbl.text = allocation.gradeSectionText
        classTeacherImgView.isHidden = !isClassTeacherClass
    }
}
