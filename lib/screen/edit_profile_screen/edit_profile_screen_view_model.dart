import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/setting_model.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/countries/select_country_controller.dart';
import 'package:orange_ui/screen/create_profile_screen/create_profile_screen_view_model.dart';
import 'package:orange_ui/service/extention/datetime_extention.dart';
import 'package:orange_ui/service/extention/list_extension.dart';
import 'package:orange_ui/service/extention/string_extention.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/app_res.dart';
import 'package:stacked/stacked.dart';

class EditProfileScreenViewModel extends BaseViewModel {
  UserData? userData;

  EditProfileScreenViewModel(this.userData);

 void init() async {
  await _waitForSettings();
  print("Settings loaded: ${SessionManager.instance.getSettings() != null}");
  getPrefSettings();
}


  Future<void> _waitForSettings() async {
  int retry = 0;

  while (SessionManager.instance.getSettings() == null && retry < 10) {
    await Future.delayed(const Duration(milliseconds: 300));
    retry++;
  }
}


  final selectCountryController = Get.find<SelectCountryController>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  DateTime selectedDob =
      DateTime.now().subtract(const Duration(days: 365 * 18));

  List<String> deleteIds = [];

  List<Images> imageList = [];

  bool showDropdown = false;
  bool isLoading = false;
  ImagePicker imagePicker = ImagePicker();

  GenderType selectedGender = GenderType.male;
  GenderType selectedGenderPref = GenderType.male;
  SettingData? settingData;

  List<Interests> interestList = [];
  List<RelationshipGoals> relationshipGoals = [];
  List<Religions> religions = [];
  List<Language> languages = [];
  List<Interests> selectedInterests = [];
  RelationshipGoals? selectedRelationShipGoal;
  Religions? selectedReligion;
  List<Language> selectedLanguages = [];

  void getPrefSettings() async {

   // settingData = SessionManager.instance.getSettings();
settingData = SessionManager.instance.getSettings();

if (settingData == null) {
  print("❌ Settings still null");
  return;
}

    interestList = (settingData?.interests ?? [])
        .where((element) => element.isDeleted == 0)
        .toList();

    relationshipGoals = (settingData?.relationshipGoals ?? [])
        .where((element) => element.isDeleted == 0)
        .toList();

   // RELIGION LIST
religions = (settingData?.religions?.isNotEmpty == true)
    ? settingData!.religions!
        .where((e) => e.isDeleted == 0)
        .toList()
    : [
        Religions(id: 1, title: 'Hindu', isDeleted: 0),
        Religions(id: 2, title: 'Muslim', isDeleted: 0),
        Religions(id: 3, title: 'Christian', isDeleted: 0),
        Religions(id: 4, title: 'Sikh', isDeleted: 0),
        Religions(id: 5, title: 'Buddhist', isDeleted: 0),
        Religions(id: 6, title: 'Jain', isDeleted: 0),
        Religions(id: 7, title: 'Other', isDeleted: 0),
      ];

// LANGUAGE LIST
languages = (settingData?.language?.isNotEmpty == true)
    ? settingData!.language!
        .where((e) => e.isDeleted == 0)
        .toList()
    : [
        Language(id: 1, title: 'English', isDeleted: 0),
        Language(id: 2, title: 'Hindi', isDeleted: 0),
        Language(id: 3, title: 'Urdu', isDeleted: 0),
        Language(id: 4, title: 'Punjabi', isDeleted: 0),
        Language(id: 5, title: 'Bengali', isDeleted: 0),
        Language(id: 6, title: 'Tamil', isDeleted: 0),
        Language(id: 7, title: 'Telugu', isDeleted: 0),
        Language(id: 8, title: 'Marathi', isDeleted: 0),
        Language(id: 9, title: 'Gujarati', isDeleted: 0),
        Language(id: 10, title: 'Malayalam', isDeleted: 0),
        Language(id: 11, title: 'Kannada', isDeleted: 0),
        Language(id: 12, title: 'Odia', isDeleted: 0),
        Language(id: 13, title: 'Assamese', isDeleted: 0),
        Language(id: 14, title: 'Other', isDeleted: 0),
      ];

getLocalData();
notifyListeners();

  }

  void getLocalData() async {
    if (userData == null) return;
    fullNameController.text = userData?.fullname ?? '';
    userNameController.text = userData?.username ?? '';
    bioController.text = userData?.bio ?? '';
    aboutController.text = userData?.about ?? '';
    instagramController.text = userData?.instagram ?? '';
    facebookController.text = userData?.facebook ?? '';
    youtubeController.text = userData?.youtube ?? '';
    imageList = userData?.images ?? [];
    selectedGender = userData!.gender;
    selectedGenderPref = userData!.genderPreferred;
    selectedDob = userData?.ageToDateTime ?? selectedDob;
    var country = selectCountryController.allCountries
        .search(userData?.country ?? '', (p0) => p0.countryName)
        .firstOrNull;
    if (country != null) {
      selectCountryController.selectCountry(country: country);
    }
    var state = selectCountryController.allStates
        .firstWhereOrNull((element) => element.name == (userData?.state ?? ''));
    if (state != null) selectCountryController.selectState(state: state);
    var city = selectCountryController.allCities
        .firstWhereOrNull((element) => element.name == (userData?.city ?? ''));
    if (city != null) selectCountryController.selectCity(city: city);
// Interests
    selectedInterests = (userData?.interests ?? '')
        .split(',')
        .map((id) => interestList
            .firstWhereOrNull((e) => e.id.toString() == id && e.isDeleted == 0))
        .whereType<Interests>()
        .toList();

    // Relationship Goal
    selectedRelationShipGoal = relationshipGoals.firstWhereOrNull(
        (e) => e.isDeleted == 0 && e.id == userData?.relationshipGoalId);

    // Religion
    // selectedReligion = religions.firstWhereOrNull((e) =>
    // e.isDeleted == 0 &&
    // e.titleRemoveEmoji
    //         .toLowerCase()
    //         .trim() ==
    //     userData?.religionKey
    //         ?.toLowerCase()
    //         .trim());

    // selectedReligion = religions.firstWhereOrNull((e) =>
    //     e.isDeleted == 0 &&
    //     e.titleRemoveEmoji == userData?.religionKey?.removeEmojis.trim());
    selectedReligion = religions.firstWhereOrNull((e) =>
    e.isDeleted == 0 &&
    e.titleRemoveEmoji
            .trim()
            .toLowerCase() ==
        userData?.religionKey
            ?.removeEmojis
            .trim()
            .toLowerCase());


    // Languages
    // selectedLanguages = (userData?.languageKeys ?? '')
    // .split(',')
    // .map((key) => languages.firstWhereOrNull((e) =>
    //     e.isDeleted == 0 &&
    //     e.title
    //             ?.removeEmojis
    //             .toLowerCase()
    //             .trim() ==
    //         key.toLowerCase().trim()))
    // .whereType<Language>()
    // .toList();

    // selectedLanguages = (userData?.languageKeys ?? '')
    //     .split(',')
    //     .map((id) => languages.firstWhereOrNull((e) =>
    //         e.isDeleted == 0 && e.title?.removeEmojis.trim() == id.trim()))
    //     .whereType<Language>()
    //     .toList();
    selectedLanguages = (userData?.languageKeys ?? '')
    .split(',')
    .map((key) => languages.firstWhereOrNull((e) =>
        e.isDeleted == 0 &&
        e.title
                ?.removeEmojis
                .trim()
                .toLowerCase() ==
            key.trim().toLowerCase()))
    .whereType<Language>()
    .toList();


    notifyListeners();
    print("========== EDIT PROFILE DEBUG ==========");

// Religion debug
print("User religionKey: '${userData?.religionKey}'");
print("Available religions:");
for (var r in religions) {
  print("→ id:${r.id} title:'${r.title}' clean:'${r.titleRemoveEmoji}'");
}

// Language debug
print("User languageKeys: '${userData?.languageKeys}'");
print("Available languages:");
for (var l in languages) {
  print("→ id:${l.id} title:'${l.title}' clean:'${l.title?.removeEmojis}'");
}

print("Selected Religion: ${selectedReligion?.title}");
print("Selected Languages: ${selectedLanguages.map((e) => e.title).toList()}");

print("========================================");

  }

  void onImageRemove(Images image, int index) {
    imageList.removeAt(index);
    if (image.id != -1) {
      deleteIds.add("${image.id}");
    }
    print("Selected Religion: ${selectedReligion?.title}");
print("Selected Languages: ${selectedLanguages.map((e) => e.title).toList()}");

notifyListeners();

  }

  void onAllScreenTap() {
    showDropdown = false;
    notifyListeners();
  }

  void onSaveTap() {
    if (imageList.isEmpty) {
      return CommonUI.snackBarWidget(S.current.pleaseAddAtLeastEtc);
    }
    if (fullNameController.text.trim().isEmpty) {
      return CommonUI.snackBarWidget(S.current.enterFullName);
    }
    if (userNameController.text.trim().isEmpty) {
      return CommonUI.snackBarWidget(S.current.enterUsername);
    }
    if (bioController.text.trim().isEmpty) {
      return CommonUI.snackBarWidget(S.current.enterBio);
    }
    if (selectCountryController.selectedCountry.value == null) {
      return CommonUI.snackBar(message: S.current.pleaseSelectCountry);
    }
    if (selectCountryController.selectedState.value == null) {
      return CommonUI.snackBar(message: S.current.pleaseSelectState);
    }
    if (selectCountryController.selectedCity.value == null) {
      return CommonUI.snackBar(message: S.current.pleaseSelectCity);
    }
    if (selectedInterests.isEmpty) {
      return CommonUI.snackBarWidget(S.current.selectInterestsToContinue);
    }
    if (selectedRelationShipGoal == null) {
      return CommonUI.snackBarWidget(S.current.selectYourRelationshipGoal);
    }
    if (selectedReligion == null) {
      return CommonUI.snackBarWidget(S.current.selectYourReligion);
    }
    if (selectedLanguages.isEmpty) {
      return CommonUI.snackBarWidget(S.current.selectYourLanguage);
    }

    List<XFile> imageFile = [];

    for (var element in imageList) {
      if (element.id == -1) {
        imageFile.add(XFile(element.image ?? ''));
      }
    }
    // print(imageFile.map((e) => e.path));
    // return;
    CommonUI.lottieLoader();
    ApiProvider()
        .updateProfile(
      images: imageFile,
      deleteImageIds: deleteIds,
      fullName: fullNameController.text.trim(),
      userName: userNameController.text.trim(),
      bio: bioController.text.trim(),
      about: aboutController.text.trim(),
      country: selectCountryController.selectedCountry.value?.countryName,
      state: selectCountryController.selectedState.value?.name,
      city: selectCountryController.selectedCity.value?.name,
      dob: selectedDob.dobFormat,
      gender: selectedGender.value,
      instagram: instagramController.text.trim(),
      facebook: facebookController.text.trim(),
      youtube: youtubeController.text.trim(),
      genderPreferred: selectedGenderPref.value,
      interest: selectedInterests.map((e) => '${e.id}').toList(),
      relationshipGoalId: selectedRelationShipGoal?.id,
      religionKey: selectedReligion?.title?.removeEmojis.trim(),
      languageKeys:
          selectedLanguages.map((e) => e.title?.removeEmojis.trim()).join(','),
    )
        .then((value) async {
      Get.back();
      SessionManager.instance.setUser(value.data);
      Get.back(result: value.data);
    });
  }

  void selectImages() async {
    final selectedImages = await imagePicker.pickMultiImage(
        imageQuality: AppRes.quality,
        maxHeight: AppRes.maxHeight,
        maxWidth: AppRes.maxWidth);

    if (selectedImages.isEmpty) return;

    for (XFile image in selectedImages) {
      imageList.add(Images(id: -1, image: image.path));
    }

    notifyListeners();
  }

  void onDateOfBirthTap(BuildContext context) {
    CommonFun.showDatePicker(
      context,
      selectedDob,
      onDateSelected: (time) {
        selectedDob = time;
        notifyListeners();
      },
    );
  }

  void onGenderTap(GenderType type) {
    selectedGender = type;
    notifyListeners();
  }

  onSelectInterestTap(Interests interest) {
    final id = interest.id;
    if (id == null) return;

    final isAlreadySelected = selectedInterests.any((e) => e.id == id);

    if (isAlreadySelected) {
      selectedInterests.removeWhere((e) => e.id == id);
    } else {
      selectedInterests.add(interest);
    }

    notifyListeners();
  }

  onRelationshipGoalTap(RelationshipGoals goal) {
    selectedRelationShipGoal = goal;
    notifyListeners();
  }

  onReligionTap(Religions religion) {
    selectedReligion = religion;
    notifyListeners();
  }

  onLanguagesTap(Language language) {
    final id = language.id;
    if (id == null) return;

    final isAlreadySelected = selectedLanguages.any((e) => e.id == id);

    if (isAlreadySelected) {
      selectedLanguages.removeWhere((e) => e.id == id);
    } else {
      selectedLanguages.add(language);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    bioController.dispose();
    aboutController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    youtubeController.dispose();
    super.dispose();
  }
}
