//
//  StringConstants.swift
//  StepLive
//
//  Created by Karthick RJ on 11/03/21.
//

import Foundation
import UIKit
struct StringConstants {
    
    //Common
    static let sureToclearNorification = "Do you want to clear all notifications?"
    static let sureToDeleteTheAnnouncement = "Are you sure to delete this announcement?"
    static let sureToDeleteTheHomework = "Are you sure to delete this assignment?"

    static let sureToDeleteTheAccount = "Are you sure to delete this account details?"
    static let password = "Password"
    static let pleaseTryAgain = "Please try Again"
    static let confirm = "Confirm"
    static let emailAddressIsNotValid = "Email address is not valid"
    static let cancel = "Cancel"
    static let noInternetConnectionFound = "No internet connection found. Please try again"
    static let somethingWentWrong = "Something went wrong"
    static let pleaseInputYourEmail = "Please input your email:"
    static let passwordCharacterCountError = "Password should be 12+ characters, include uppercase, lowercase, number, and special character"
    static let pleaseGiveAValidEmailAddress = "Please enter a valid email address"
    static let sessionExpired = "Oops! Your session has expired. Please log in again."
    static let validMobile = "Please provide valid mobile number"
    static let enterMessage = "Enter the message"
    static let reportPost = "Report Post"
    static let deletePost = "Delete Post"
    static let sureToLogoutThisSession = "Do you want to logout this session?"
    static let sureToLogoutAllSession = "Do you want to logout from all device?"
    static let sureToRemoveFromCart = "Are you sure you want to remove the item from cart?"
    static let selectDob = "Please select date of birth"
    static let selectCountry = "Please select the country"
    static let selectNationality = "Please select the nationality"

    static let amountWarning = "Amount must be between 1 to 100000"
    static let pleaseGiveAValidWalletAddress = "Please give a valid wallet address"
    static let pleaseSelectWalletAddress = "Please select a wallet address"

    static let pleaseEnterAmount = "Please enter a valid amount"
    static let pleaseGiveID = "Please enter a valid transaction id"
    static let sureToDownload = "Do you want to download transaction history?"
    static let sureToDownloadInvoice = "Do you want to download invoice?"
    static let sureToActivateEur = "Are you sure you want to activate EUR?"
    static let lossData = "You've entered some information. if you skip,all your data will be lost. Are you sure you want to skip?"
    static let lossDataWhenBack = "You’ve entered some information. Going back will erase all data. Are you sure you want to proceed?"
    
    static let lossDataWhenClose = "You’ve entered some information. Closing now will erase all data. Are you sure you want to close?"
    
    static let share = "Share"
    static let shareProfile = "Share Profile"
    static let Required = "Required"
    static let NameRequired = "Enter a proper name"
    static let companyName = "Enter a proper company name"
    static let regnumber = "Registration Number Required "
    static let regdate = "Registered Date Required "
    static let Unsaved = "Unsaved Data"
    static let uploadDoc = "Please upload the document"

    static let kycPending = "KYC setup is pending. Please complete it to continue."
    static let kybPending = "KYB setup is pending. Please complete it to continue."
    static let onboardingPending = "Onboarding is not completed yet. Please complete it!"
    static let enterOtp = "Please enter 6 Digit OTP"

    
    //ManageProVC
    static let addProfile = "Add Profile"
    
    static let selecteCountry = "Select Country"
    static let selecteState = "Select State"
    static let selecteAccType = "Select Account Type"
    static let selecteDocType = "Select Document Type"

    struct transactionHeadingArray {
        static let buy = "Buy"
        static let sell = "Sell"
        static let deposited = "Deposit"
        static let swap = "Swap"
        static let withdraw = "Withdraw"
        static let exchange = "Exchange"
        static let trade = "Trade"

    }
    
    struct legalArray {
        
        static let privacyPolicy = "Privacy Policy"
        static let termsOfUse = "Terms And Conditions"
    }
    
    struct notiSecondTitlesArray {
        
        static let toYourMobileOrTabletDevices = "To your mobile or tablet devices"
        static let youWillGetEmailNoti = "You will get email notifications for the important updates"
    }
    
    static let pushNotifications = "Notification Settings"
    
    struct sectionArray {
        
        static let notifications = "Notifications"
        static let legal = "Legal"
    }
    
    //ChangePasswordVC
    static let newPasswordsDoNotMatch = "Passwords do not match"
    static let newPasswordIsNotValid = "New password is not valid"
    static let pleaseEnterAValidPassword = "Enter a valid password"
    static let fieldsCantBeEmpty = "Fields can't be empty"
    static let fieldCantBeEmpty = "Field can't be empty"

    //SignInVC
    static let email = "Email"
    static let help = "Help"
    static let contact = "Contact"
    static let about = "About"
    
    //CardsVC
    static let cards = "Cards"
    
    //EditAccountVC
    static let chooseImage = "Choose Image"
    static let chooseVideo = "Choose Video"
    static let chooseFile = "Choose File"

    static let camera = "Camera"
    static let gallery = "Gallery"
    static let document = "Document"

    static let warning = "Warning"
    static let youDontHaveCamera = "You don't have camera"
    static let ok = "OK"
    static let youDontHavePerissionToAccessGallery = "You don't have permission to access gallery."
    static let updatedSuccessfully = "Updated successfully"
    
    //EditProfileVC
    static let editProfile = "Edit Profile"
    
    //AppSettingsVC
    static let appSettings = "App Settings"
    
    //AccountVC
    static let account = "Account"
    static let areYouSureToDeleteAccount = "Your account will be deleted and cannot be undone"
    static let areYouSureToDeleteUser = "Are you sure to delete this user?"
    
    static let passwordIsRequired = "Password is required"
    static let enterPasswordToDelete = "Enter your password to delete the account"
    static let appLanguageChange = "Choose Language"
    static let titleIsRequired = "Title is required"
    
    //WhoIsWatchingPage
    static let whoIsWatchingPage = "Who is watching?"
    
    //MoreVC
    static let areYouSureToLogout = "Are you sure to logout?"
    static let yes = "YES"
    static let no = "NO"
    
    //CategoriesVC
    static let categories = "Categories"
    
    //SearchVC
    static let search = "Search"
    
    //Bank details
    static let provideName = "Provide a valid name"
    static let provideUniqueID = "Provide a valid unique ID"
    static let provideTitle = "Provide a valid title"
    static let provideDesc = "Provide a valid description"

    static let provideAccountNumber = "Please provide valid account number"
    static let provideRouteNumber = "Please provider valid route number"
    static let provideReaccountNumber = "Please provide reaccount number"
    static let pleaseLogin = "Please login/signup to continue"
    static let loginOrSignup = "Login/Signup"
    
    static let sureTounblockThisUser = "Are you sure to unblock this user?"
    static let sureToCancel = "Are you sure to cancel this request?"
    static let sureToReturn = "Are you sure to return this product?"
    
    static let sureToDeleteSender = "Are you sure want to delete this sender ?"
    static let cancelWithdraw = "Are you sure want to cancel withdraw ?"
    static let sureToDeleteRecipient = "Are you sure want to delete this recipient ?"
    static let sureToUnblockCard = "Are you sure want to unblock this card ?"
    static let sureToDeleteBeneficiary = "Are you sure want to delete this beneficiary ?"
    static let sureToDeactivateBeneficiary = "Are you sure want to deactivate this beneficiary ?"

    static let sureToactivateBeneficiary = "Are you sure want to activate this beneficiary ?"
    static let sureToBlockBeneficiary = "Are you sure want to block this beneficiary ?"

    // Business
    
    static let provideAddress = "Provide a valid address"
    static let provideCity = "Provide a valid city"
    static let provideState = "Provide a valid state"
    static let providePincode = "Provide a valid pincode"
    static let provideBankcode = "Provide a valid bank code"

    
    // Beneficiaries
    
    static let acticateBeneficiary = "Activate Beneficiary"
    static let deacticateBeneficiary = "Deactivate Beneficiary"

    static let blockBeneficiary = "Block Beneficiary"
    static let unblockBeneficiary = "UnBlock Beneficiary"

    static let deleteBeneficiary = "Delete Beneficiary"

}
