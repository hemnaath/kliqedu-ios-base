//
//  Constants.swift
//  StepLive
//
//

import Foundation
import UIKit

struct Constants {

    // staging
    
//    static let baseUrl = "https://herald-retail-api-qa.heraldex.com/api/v1/"
    static let baseUrl = "https://api.kliqedu.com/api/"

    static let keyFile = "T+lih90otH7o/Osg5Ttdzd2/qln9WMwupgJpz8IZswc="
    static let socketUrl = "https://ljdfertyh-socket.herald.exchange/"

    
    static let ethApiKey = "B34RQKNPZUV8IM6866DQ58WCS2Q6SWAP8V"
    static let bnbApiKey = "QFBTFQS48VSF8VF9JVSCJTUWXCZC22DUJF"
    static let polApiKey = "KYV61TJQU5RDMTGY1D95J8R61HWCR9T7KT"
    
    static let ethchaninid =  11155111
    static let bnbchaninid =  97
    static let polchaninid =  80002
    
    static let EthUrl = "https://api.etherscan.io/v2/api"
    static let BNBUrl = "https://api.etherscan.io/v2/api"
    static let SolUrl = "https://api.testnet.solana.com/"
    static let btcUrl = "https://efi-exchange.blockstall.com:9001/api/user/bitcoin/start_watch_wallet"
    static let tronUrl = "https://api.shasta.trongrid.io/v1/accounts/"
    static let polUrl = "https://api.etherscan.io/v2/api"
    
    
    // production
    
  //  static let baseUrl = "https://grdpdxkx.herald.exchange/api/v1/"
//    static let keyFile = "ntIhVzH2Ay3J645N4czDlquPHKaR5R+yb7f3IwcYXys="
//    static let socketUrl = "https://massive-heraldex-socket.rare-able.com:1873/"
//   // static let socketUrl = "https://e8c4ac586252.ngrok-free.app/"
//
//    static let ethApiKey = "QFBTFQS48VSF8VF9JVSCJTUWXCZC22DUJF"
//    static let bnbApiKey = "K3VYMP8J3TZNWQENMQM8M8D745HHV5Y9A3"
//    static let polApiKey = "QFBTFQS48VSF8VF9JVSCJTUWXCZC22DUJF"
//    
//    static let ethchaninid =  1
//    static let bnbchaninid =  56
//    static let polchaninid =  137
//    
//    static let EthUrl = "https://api.etherscan.io/v2/api"
//    static let BNBUrl = "https://api.etherscan.io/v2/api"
//    static let SolUrl = "https://api.mainnet-beta.solana.com/"
//    static let btcUrl = "https://woowga-node.herald.exchange:9001/api/user/bitcoin/start_watch_wallet"
//    static let tronUrl = "https://api.trongrid.io/v1/accounts/"
//    static let polUrl = "https://api.etherscan.io/v2/api"
//    
    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    
    static let currencyCode = "USD"
    static let language = "Language"
    
    static let mobile_headers = [
        "genesis": "grdpdxkx.herald.exchange",
        "x-mobile-secret": "8ebc7fde7a65d00b118eaaf1d9f9c7b0684204e70c52e87ff6266bc8b583800c"
    ]
    
    struct Keys {
        
        // User logged in status
        
        static let isLoggedIn = "is_logged_in"
        static let json_Key = "jsonKeys"
        
        static let gender     = "gender"
        // For granting access token
        static let accessTokenKey = "user_auth_token"
        static let qrCodeKey = "qr_code"
        static let secretKey = "secretKey"
        
        // User Id
        static let userIdKey      = "ich_userId"
        static let passwordKey = "passwordKey"
        static let kycStatusKey = "kyc_status"
        
        // Current user type
        static let loginTypeKey    = "login_type"
        // User's current profile image
        static let userPicKey     = "user_profile_image"
        
        // User name
        static let userNameKey    = "username"
        static let firstNameKey = "first_name"
        static let lastNameKey = "last_name"
        static let middleNameKey = "middle_name"
        static let joinDateKey = "join_date"
        static let dobKey = "dob"
        static let parentIdKey = "parent_id"
        static let gradeIdKey = "grade_id"
        static let sectionIdKey = "section_id"
        static let groupIdKey = "group_id"
        static let bloodGroupKey = "blood_group"
        static let statusKey = "status"
        static let ageKey = "age"
        static let orgIdKey = "org_id"
        static let religionKey = "religion"
        static let casteKey = "caste"
        static let createdAtKey = "created_at"
        static let updatedAtKey = "updated_at"
        static let rollNumberKey = "roll_number"
        static let dashboardPermissionKey = "dashboard_permission"
        static let teacherPermissionKey = "teacher_permission"
        static let feesPermissionKey = "fees_permission"
        static let homeworkPermissionKey = "homework_permission"
        static let leavePermissionKey = "leave_permission"
        static let announcementsPermissionKey = "announcements_permission"
        static let holidayPermissionKey = "holiday_permission"
        static let settingsPermissionKey = "settings_permission"
        
        // Device Token
        static let deviceTokenKey = "device_token"
        // Email address
        static let emailIdKey = "ich_email"
        static let userUniqueIdKey  = "useruniqueid"
        static let kycVerified  = "kycVerified"
        
        static let onboardingKey  = "onboarding"
        static let onboarding_completed = "onboarding_completed"
        static let roleKey  = "role_type"
        
        static let email_statusKey  = "email_status"
        
        static let mobilecountrycodeKey  = "mobile_country_code"
        static let resetTok = "resetTok"
        static let apiKey = "apiKey"
        static let saltKey = "saltKey"
        static let private_key = "private_key"
        static let finalSignature = "final_Sig"
        static let is2FAEnabled = "is_2fa_enabled"
        static let activateUSDKey = "activateUSD"
        static let activateEurKey = "activateEur"
        static let kybStatusKey = "kybStatus"
        static let kycVerifiedKey = "kycVerified"
        
        // User phone num
        static let phoneNUmKey = "mobile"
        
        // payment mode
        static let paymentMode = "payment_mode"
        
        //User social unique id for social login
        static let socialUniqueId = "social_unique_id"
        
        //User's about me aka description'
        static let aboutMeDesc = "description"
        
        //push and email noti settings'
        static let pushNotiStatus = "push_noti_status"
        static let emailNotiStatus = "email_noti_status"
        
        static let walletBalance = "walletBal"
        
        static let faceID    = "faceid"
        static let passcodeKey    = "passcode"
        //static pages****
        
        static let aboutTitle = "about"
        static let aboutDesc = "about_value"
        static let contactTitle = "contact"
        static let contactDesc = "contact_value"
        static let privacyTitle = "privacy"
        static let privacyDesc = "privacy_value"
        static let policyTitle = "policy"
        static let policyDesc = "policy_value"
        static let termsTitle = "terms"
        static let termsDesc = "terms_value"
        static let helpTitle = "help"
        static let helpDesc = "help_value"
        
    }
    
    struct SegueIds {
        
        static let homeVC = "showHomeVC"
        static let loginVC = "showLoginVC"
    }
    
    struct ViewControllers {
        
        //login pages
        static let homeVC  = "HomeVC"
        static let launchVC  = "LaunchVC"
        
        static let welcomeVC = "WelcomeController"
        static let signinVC = "SignInVC"
        static let baseTabbarController = "BaseTabbarController"
        static let verifyEmailVC = "VerifyEmailVC"
        
        static let enterPasscodeVC = "EnterPasscodeVC"
        static let reenterPasscodeVC = "ReenterPasscodeVC"
        static let passcodeVC = "PasscodeVC"
    }
    
    struct Cells {
        
        static let profileTCell = "ProfileTCell"
        static let settingsCell = "SettingsCell"
    }
    struct SectionHeader {
        
        static let homeSectionHeader = "SectionHeader'"
    }
    
    /// theame Color of app
    struct CommonColors {
        
        static let googleColor = UIColor(red: 219/255.0, green: 74/255.0, blue: 57/255.0, alpha: 1.0)
        static let fbColor = UIColor(red: 59/255.0, green: 89/255.0, blue: 152/255.0, alpha: 1.0)
        static let modalColor = UIColor(red: 50/255.0, green: 58/255.0, blue: 68/255.0, alpha: 1.0)
        static let theameGreenColor = UIColor(red: 0/255.0, green: 199/255.0, blue: 94/255.0, alpha: 1.0)
        
        static let socialLoginBackGroundColor = UIColor(red: 243/255.0, green: 239/255.0, blue: 235/255.0, alpha: 1.0)
        static let redColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    }
    
    /// common dateformat
    struct dateFormat {
        
        static let dateFormat = "yyyy-MM-dd"
    }
    
    //notifications
    struct Notifications {
        
        static let networkConnected = "network_connected"
        static let networkDisconnected = "network_diconnected"
        static let updateCartBadge = "update_cart_badge"
        static let shortcutAction = "quick_action_notification"
        static let openQuickOrder = "quick_order_action"
        
    }
    
    //storybord ids
    struct StoryboardIds {
        
        static let mainSb = "Main"
        static let homeSb = "Home"
        static let settingsSB = "Settings"
        static let loginSB = "Login"
        
    }
    //urls for api call
    struct Urls {
        
        static let manualLoginUrl = "auth/login"
        static let categoryList = "categories_list"
        static let soacialLoginUrl = "register"
        static let deleteAccountUrl = "user/acrhive_user"
        static let logOutUrl = "auth/logout"
        static let editProfileUrl = "user/revise_user"
        static let loginLocationResendUrl = "login_location/resend"
        static let loginLocationVerifyUrl = "auth/location/verify"
        static let forceResetPasswordUrl = "auth/password/force_reset"
        static let usdDocUploadUrl = "usd_documents/store"
        static let editProfilePicUrl = "upload_profile_picture"
        
        static let removeProfilePicUrl = "remove_profile_picture"
        
        static let changePasswordUrl = "user/revise_authentication"
        static let verifyEmailUrl = "auth/verify-email"
        static let verifyEmailResendUrl = "auth/resend-otp"
        static let staticPageUrl = "lookup/constant_pages"
        static let staticPageIndexUrl = "static_pages"
        
        static let updateAddressUrl = "user/revise_premises"
        static let tfaEnableUrl = "user/get_auth_details"
        static let tfaActivateUrl = "user/enbl_auth"
        static let tfaUpdateUrl = "user/approve_auth_code"
        static let supportedCountriesUrl = "lookup/allowed_countries"
        static let getAccessTokenUrl = "trustident/access_token"
        static let getBusinessAddressUrl = "user/get_user_tenant_details"
        static let referralCodeUrl = "user/get_referrals"
        
        static let teacherDashboardUrl = "teacher/dashboard/get"
        static let parentDashboardUrl = "parent/dashboard/get"

        static let teacherHolidaysUrl = "teacher/holiday/list"
        static let parentHolidaysUrl = "parent/holiday/list"
        
        static let studentsUrl = "teacher/student/list"
        static let studentInfoUrl = "teacher/student"

        static let teachersListUrl = "parent/teacher/list"
        
        
        static let teacherAnnouncementListUrl = "teacher/announcement/list"
        static let parentAnnouncementListUrl = "parent/announcement/list"
        
        static let teacherChangePasswordUrl = "teacher/settings/change-password"
        static let parentChangePasswordUrl = "parent/settings/change-password"
        
        static let teacherDelAccUrl = "teacher/settings/delete-account"
        static let parentDelAccUrl = "parent/settings/delete-account"
        
       
        static let gradesUrl = "teacher/lookup/grades"
        static let sectionsUrl = "teacher/lookup/sections"
        static let groupsUrl = "teacher/lookup/groups"
        static let subjectsUrl = "teacher/lookup/subjects"
        static let leaveTypesUrl = "teacher/lookup/leave-types"

        
        static let createAnnouncementUrl = "teacher/announcement/create"
        static let deleteAnnouncementUrl = "teacher/announcement/delete"
        static let updateAnnouncementUrl = "teacher/announcement/update"
        static let viewAnnouncementUrl = "teacher/announcement/view"

        static let feesListUrl = "parent/fees/list"

        static let teacherHomeworkListUrl = "teacher/homework/list"
        static let parentHomeworkUrl = "parent/homework/list"

        static let createHomeworkUrl = "teacher/homework/create"
        static let deleteHomeworkUrl = "teacher/homework/delete"
        static let updateHomeworkUrl = "teacher/homework/update"
        static let viewHomeworkUrl = "teacher/homework/view"

        static let teachercreateLeaveUrl = "teacher/leave/apply"
        static let teacherdeleteLeaveUrl = "teacher/leave/delete"
        static let teacherupdateLeaveUrl = "teacher/leave/update"
        static let teacherleaveListUrl = "teacher/leave/list"
        
        static let parentcreateLeaveUrl = "parent/leave/apply"
        static let parentdeleteLeaveUrl = "parent/leave/delete"
        static let parentupdateLeaveUrl = "parent/leave/update"
        static let parentleaveListUrl = "parent/leave/list"
        
        
        static let profileUrl = "teacher/settings/profile"

        // Onboarding
        static let onboardingUrl = "initiate/individual"
        static let businessOnboardingUrl = "initiate/business"
        static let sectorsUrl = "lookup/sectors_list"

        // KYC/KYB
        
        static let supportedDocsUrl = "user/supported_docs_list"
        static let verificationDetailsUrl = "user/verification_details"
        static let verifyKycUrl = "user/verify_kyc"
        static let verifyKybUrl = "user/kyb_verify"

        
        static let getAdminAccount  = "supervisor/bank_account"
        static let getAdminWallet  = "supervisor/wallets"
        static let getUserAddress = "user/get_user_premises"
        
        // Activate EUR / USD
        static let activateIndiEur  = "enable_eur/individual"
        static let activateBusiEur  = "enable_eur/business"
        
        static let activateIndiUsd  = "individual/activate_usd"
        static let activateBusiUsd  = "business/activate_usd"
        
        // Backup codes
        static let viewBackupCodesUrl = "user/view_recovery_codes"
        static let regenerateBackupCodesUrl = "user/regenerate_recovery_codes"
        
        // Forgot password
        
        static let forgotPasswordUrl = "auth/forget-password"
        static let forgotPasswordCodeUrl = "auth/password/verify_reset_code"
        static let resetPasswordUrl = "auth/reset-password"
        
        // Two Step
        
        static let twoStepVerifyUrl = "two_step_auth_update"
        static let twoStepVerifyResendUrl = "resend_two_step_auth_code"
        static let twoStepVerificationUrl = "two_step_auth_login"
        static let check2FACodeUrl = "user/check_auth_code"
                
        // WishList
        
        static let whiteListUrl = "trusted_wallet_addresses"
        static let whiteListDeleteUrl = "trusted_wallet_addresses/delete"
        static let whiteListStoreUrl = "trusted_wallet_address/store"
        
        // WithinPay user
        
        static let withinpayUserListUrl = "withinpay_users"
        static let withinpayUserDeleteUrl = "withinpay_users/delete"
        static let withinpayUserStoreUrl = "withinpay_users/store"
        static let withinpayUserSendMoneyUrl = "internal_transfer"
        
        //transaction List
        
        static let transactionHistory  = "m_transactions"
        static let transactionStore  = "m_transactions/store"
        static let transactionShow  = "m_transactions/show"
        
        //wallet
        
        static let walletsUrl = "vaults"
        static let walletsView  = "vault_view"
        static let walletsPayments  = "vault_payments"
        static let walletsPaymentsView  = "wallet_payments/view"
        
        
        // Export
        static let walletsPaymentsExport  = "vault_payments/export"
        static let withdrawExport  = "user_payouts/export"
        static let swapExport  = "payments/swap_export"
        static let depositExport  = "payments/deposit_export"
        static let buyExport  = "payments/buy_export"
        static let sellExport  = "payments/sell_export"
        static let exchangeExport  = "payments/exchange_export"
        static let tradeExport  = "payments/trade_export"
        
        //withdraw
        
        static let downloadInvoiceWithdraw  = "user_payout/invoice"
        
        //transaction List
        
        static let buyTransactionHistory  = "payments/buy"
        static let sellTransactionHistory  = "payments/sell"
        static let depositTransactionHistory  = "payments/deposit"
        static let swapTransactionHistory  = "payments/swap"
        static let exchangeTransactionHistory  = "payments/exchange"
        static let tradeTransactionHistory  = "payments/trade"
        static let withdrawHistory  = "payments/withdraw"

        static let buyTransactionView  = "buy_payments/view"
        static let sellTransactionView  = "sell_payments/view"
        static let depositTransactionView  = "deposit_payments/view"
        static let swapTransactionView  = "swap_payments/view"
        static let withdrawTransactionView  = "payouts/view"
        static let exchangeShowUrl  = "conversion/show"

        // Accounts
        
        static let serviceCountriesList  = "service_countries"
        static let serviceBankList  = "service_banks"
        static let mobileCountryCodesList  = "mobile_country_codes"
        static let clearingCodesList  = "branch_codes"
        
        // Countries
        static let mobileCountryCodes  = "lookup/country_dial_codes"
        static let nationalitiesCodes  = "lookup/origins"
        static let countriesCodes  = "lookup/countries"
        
        // Buy
        static let buyBankUrl  = "buy/bank"
        static let buyWalletUrl  = "buy/wallet"
        
        // Sell
        static let sellCryptoUrl  = "liquidate/tokens/by/hash"
        static let sellWalletUrl  = "liquidate/tokens/by/wallet"
        
        // Exchange
        
        static let exchangeTokensUrl  = "conversion/add"
        
        // Trade
        
        static let tradeTokenUrl  = "efi/trade_tokens"
        static let currencyPairsUrl  = "get_tenders"
        static let tradeShowUrl  = "efi/trade_tokens_view"
        
        
        // Deposit
        
        static let depositBankUrl  = "topup/fiat"
        static let depositCryptoUrl  = "topup/crypto"
        
        //Bank details
        
        static let addBankDetails = "payee/create_account"
        static let bankAccList = "payee/get_accounts"
        static let viewBankDetails = "payee/get_account"
        static let beneficiaryDelete  = "payee/delete_account"
        static let beneficiaryStatus  = "beneficiary_accounts/status"
        static let purposeofPayments  = "purpose_of_payments"
        
        // Withdraw
        
        static let withdrawUrl  = "disbursement/fiat"
        static let withdrawCryptoUrl  = "disbursement/crypto"
        static let withdrawEficyentUrl  = "virtual_accounts/fund_transfer"
        static let bvnkFeesUrl  = "lookup/solid_vault_fees"
        
        // Swap
        
        static let getSwapWallets  = "transform/get_wallets"
        static let getCurrencies  = "get_legal_tenders"
        static let commissionRanges  = "fee_tiers"
        
        static let ccSwapTokens  = "transform/tokens"
        static let ffSwapTokens  = "transform/fiats"
        static let cfSwapTokens  = "transform/crypto_fiat"
        static let fcSwapTokens  = "transform/fiat_crypto"
        
        // Accounts
        static let accounts  = "digital_accounts"
        static let virtualAccountShowUrl  = "digital_account"

        static let activateEur  = "activate_eur"
        
        static let activateUsd  = "activate_usd"
        static let getActivatEURUSD = "activated_usd_eur_details"
        
        static let exchangeRateUrl = "exchange_rates"

    }
}
struct CurrencyConstants {

    static let currencyNames: [String: String] = [
        "BTC": "Bitcoin",
        "USDT": "Tether",
        "ETH": "Ethereum",
        "BNB": "Binance Coin",
        "SOL": "Solana",
        "USDC": "USD Coin",
        "POL": "Polygon",
        "TRX": "Tron",
        "EUR": "Euro",
        "USD": "US Doller"
    ]
}
let alpha2ToAlpha3: [String: String] = [
    "AF": "AFG", "AX": "ALA", "AL": "ALB", "DZ": "DZA", "AS": "ASM",
    "AD": "AND", "AO": "AGO", "AI": "AIA", "AQ": "ATA", "AG": "ATG",
    "AR": "ARG", "AM": "ARM", "AW": "ABW", "AU": "AUS", "AT": "AUT",
    "AZ": "AZE", "BS": "BHS", "BH": "BHR", "BD": "BGD", "BB": "BRB",
    "BY": "BLR", "BE": "BEL", "BZ": "BLZ", "BJ": "BEN", "BM": "BMU",
    "BT": "BTN", "BO": "BOL", "BA": "BIH", "BW": "BWA", "BV": "BVT",
    "BR": "BRA", "IO": "IOT", "BN": "BRN", "BG": "BGR", "BF": "BFA",
    "BI": "BDI", "KH": "KHM", "CM": "CMR", "CA": "CAN", "CV": "CPV",
    "KY": "CYM", "CF": "CAF", "TD": "TCD", "CL": "CHL", "CN": "CHN",
    "CX": "CXR", "CC": "CCK", "CO": "COL", "KM": "COM", "CG": "COG",
    "CD": "COD", "CK": "COK", "CR": "CRI", "CI": "CIV", "HR": "HRV",
    "CU": "CUB", "CY": "CYP", "CZ": "CZE", "DK": "DNK", "DJ": "DJI",
    "DM": "DMA", "DO": "DOM", "EC": "ECU", "EG": "EGY", "SV": "SLV",
    "GQ": "GNQ", "ER": "ERI", "EE": "EST", "ET": "ETH", "FK": "FLK",
    "FO": "FRO", "FJ": "FJI", "FI": "FIN", "FR": "FRA", "GF": "GUF",
    "PF": "PYF", "TF": "ATF", "GA": "GAB", "GM": "GMB", "GE": "GEO",
    "DE": "DEU", "GH": "GHA", "GI": "GIB", "GR": "GRC", "GL": "GRL",
    "GD": "GRD", "GP": "GLP", "GU": "GUM", "GT": "GTM", "GG": "GGY",
    "GN": "GIN", "GW": "GNB", "GY": "GUY", "HT": "HTI", "HM": "HMD",
    "VA": "VAT", "HN": "HND", "HK": "HKG", "HU": "HUN", "IS": "ISL",
    "IN": "IND", "ID": "IDN", "IR": "IRN", "IQ": "IRQ", "IE": "IRL",
    "IM": "IMN", "IL": "ISR", "IT": "ITA", "JM": "JAM", "JP": "JPN",
    "JE": "JEY", "JO": "JOR", "KZ": "KAZ", "KE": "KEN", "KI": "KIR",
    "KP": "PRK", "KR": "KOR", "KW": "KWT", "KG": "KGZ", "LA": "LAO",
    "LV": "LVA", "LB": "LBN", "LS": "LSO", "LR": "LBR", "LY": "LBY",
    "LI": "LIE", "LT": "LTU", "LU": "LUX", "MO": "MAC", "MK": "MKD",
    "MG": "MDG", "MW": "MWI", "MY": "MYS", "MV": "MDV", "ML": "MLI",
    "MT": "MLT", "MH": "MHL", "MQ": "MTQ", "MR": "MRT", "MU": "MUS",
    "YT": "MYT", "MX": "MEX", "FM": "FSM", "MD": "MDA", "MC": "MCO",
    "MN": "MNG", "ME": "MNE", "MS": "MSR", "MA": "MAR", "MZ": "MOZ",
    "MM": "MMR", "NA": "NAM", "NR": "NRU", "NP": "NPL", "NL": "NLD",
    "NC": "NCL", "NZ": "NZL", "NI": "NIC", "NE": "NER", "NG": "NGA",
    "NU": "NIU", "NF": "NFK", "MP": "MNP", "NO": "NOR", "OM": "OMN",
    "PK": "PAK", "PW": "PLW", "PS": "PSE", "PA": "PAN", "PG": "PNG",
    "PY": "PRY", "PE": "PER", "PH": "PHL", "PN": "PCN", "PL": "POL",
    "PT": "PRT", "PR": "PRI", "QA": "QAT", "RE": "REU", "RO": "ROU",
    "RU": "RUS", "RW": "RWA", "BL": "BLM", "SH": "SHN", "KN": "KNA",
    "LC": "LCA", "MF": "MAF", "PM": "SPM", "VC": "VCT", "WS": "WSM",
    "SM": "SMR", "ST": "STP", "SA": "SAU", "SN": "SEN", "RS": "SRB",
    "SC": "SYC", "SL": "SLE", "SG": "SGP", "SX": "SXM", "SK": "SVK",
    "SI": "SVN", "SB": "SLB", "SO": "SOM", "ZA": "ZAF", "GS": "SGS",
    "SS": "SSD", "ES": "ESP", "LK": "LKA", "SD": "SDN", "SR": "SUR",
    "SJ": "SJM", "SZ": "SWZ", "SE": "SWE", "CH": "CHE", "SY": "SYR",
    "TW": "TWN", "TJ": "TJK", "TZ": "TZA", "TH": "THA", "TL": "TLS",
    "TG": "TGO", "TK": "TKL", "TO": "TON", "TT": "TTO", "TN": "TUN",
    "TR": "TUR", "TM": "TKM", "TC": "TCA", "TV": "TUV", "UG": "UGA",
    "UA": "UKR", "AE": "ARE", "GB": "GBR", "US": "USA", "UM": "UMI",
    "UY": "URY", "UZ": "UZB", "VU": "VUT", "VE": "VEN", "VN": "VNM",
    "VG": "VGB", "VI": "VIR", "WF": "WLF", "EH": "ESH", "YE": "YEM",
    "ZM": "ZMB", "ZW": "ZWE"]

let alpha3ToAlpha2: [String: String] = [
    "AFG": "AF", "ALA": "AX", "ALB": "AL", "DZA": "DZ", "ASM": "AS",
    "AND": "AD", "AGO": "AO", "AIA": "AI", "ATA": "AQ", "ATG": "AG",
    "ARG": "AR", "ARM": "AM", "ABW": "AW", "AUS": "AU", "AUT": "AT",
    "AZE": "AZ", "BHS": "BS", "BHR": "BH", "BGD": "BD", "BRB": "BB",
    "BLR": "BY", "BEL": "BE", "BLZ": "BZ", "BEN": "BJ", "BMU": "BM",
    "BTN": "BT", "BOL": "BO", "BIH": "BA", "BWA": "BW", "BVT": "BV",
    "BRA": "BR", "IOT": "IO", "BRN": "BN", "BGR": "BG", "BFA": "BF",
    "BDI": "BI", "KHM": "KH", "CMR": "CM", "CAN": "CA", "CPV": "CV",
    "CYM": "KY", "CAF": "CF", "TCD": "TD", "CHL": "CL", "CHN": "CN",
    "CXR": "CX", "CCK": "CC", "COL": "CO", "COM": "KM", "COG": "CG",
    "COD": "CD", "COK": "CK", "CRI": "CR", "CIV": "CI", "HRV": "HR",
    "CUB": "CU", "CYP": "CY", "CZE": "CZ", "DNK": "DK", "DJI": "DJ",
    "DMA": "DM", "DOM": "DO", "ECU": "EC", "EGY": "EG", "SLV": "SV",
    "GNQ": "GQ", "ERI": "ER", "EST": "EE", "ETH": "ET", "FLK": "FK",
    "FRO": "FO", "FJI": "FJ", "FIN": "FI", "FRA": "FR", "GUF": "GF",
    "PYF": "PF", "ATF": "TF", "GAB": "GA", "GMB": "GM", "GEO": "GE",
    "DEU": "DE", "GHA": "GH", "GIB": "GI", "GRC": "GR", "GRL": "GL",
    "GRD": "GD", "GLP": "GP", "GUM": "GU", "GTM": "GT", "GGY": "GG",
    "GIN": "GN", "GNB": "GW", "GUY": "GY", "HTI": "HT", "HMD": "HM",
    "VAT": "VA", "HND": "HN", "HKG": "HK", "HUN": "HU", "ISL": "IS",
    "IND": "IN", "IDN": "ID", "IRN": "IR", "IRQ": "IQ", "IRL": "IE",
    "IMN": "IM", "ISR": "IL", "ITA": "IT", "JAM": "JM", "JPN": "JP",
    "JEY": "JE", "JOR": "JO", "KAZ": "KZ", "KEN": "KE", "KIR": "KI",
    "PRK": "KP", "KOR": "KR", "KWT": "KW", "KGZ": "KG", "LAO": "LA",
    "LVA": "LV", "LBN": "LB", "LSO": "LS", "LBR": "LR", "LBY": "LY",
    "LIE": "LI", "LTU": "LT", "LUX": "LU", "MAC": "MO", "MKD": "MK",
    "MDG": "MG", "MWI": "MW", "MYS": "MY", "MDV": "MV", "MLI": "ML",
    "MLT": "MT", "MHL": "MH", "MTQ": "MQ", "MRT": "MR", "MUS": "MU",
    "MYT": "YT", "MEX": "MX", "FSM": "FM", "MDA": "MD", "MCO": "MC",
    "MNG": "MN", "MNE": "ME", "MSR": "MS", "MAR": "MA", "MOZ": "MZ",
    "MMR": "MM", "NAM": "NA", "NRU": "NR", "NPL": "NP", "NLD": "NL",
    "NCL": "NC", "NZL": "NZ", "NIC": "NI", "NER": "NE", "NGA": "NG",
    "NIU": "NU", "NFK": "NF", "MNP": "MP", "NOR": "NO", "OMN": "OM",
    "PAK": "PK", "PLW": "PW", "PSE": "PS", "PAN": "PA", "PNG": "PG",
    "PRY": "PY", "PER": "PE", "PHL": "PH", "PCN": "PN", "POL": "PL",
    "PRT": "PT", "PRI": "PR", "QAT": "QA", "REU": "RE", "ROU": "RO",
    "RUS": "RU", "RWA": "RW", "BLM": "BL", "SHN": "SH", "KNA": "KN",
    "LCA": "LC", "MAF": "MF", "SPM": "PM", "VCT": "VC", "WSM": "WS",
    "SMR": "SM", "STP": "ST", "SAU": "SA", "SEN": "SN", "SRB": "RS",
    "SYC": "SC", "SLE": "SL", "SGP": "SG", "SXM": "SX", "SVK": "SK",
    "SVN": "SI", "SLB": "SB", "SOM": "SO", "ZAF": "ZA", "SGS": "GS",
    "SSD": "SS", "ESP": "ES", "LKA": "LK", "SDN": "SD", "SUR": "SR",
    "SJM": "SJ", "SWZ": "SZ", "SWE": "SE", "CHE": "CH", "SYR": "SYR",
    "TWN": "TW", "TJK": "TJ", "TZA": "TZ", "THA": "TH", "TLS": "TL",
    "TGO": "TG", "TKL": "TK", "TON": "TO", "TTO": "TT", "TUN": "TN",
    "TUR": "TR", "TKM": "TM", "TCA": "TC", "TUV": "TV", "UGA": "UG",
    "UKR": "UA", "ARE": "AE", "GBR": "GB", "USA": "US", "UMI": "UM",
    "URY": "UY", "UZB": "UZ", "VUT": "VU", "VEN": "VE", "VNM": "VN",
    "VGB": "VG", "VIR": "VI", "WLF": "WF", "ESH": "EH", "YEM": "YE",
    "ZMB": "ZM", "ZWE": "ZW"
]
