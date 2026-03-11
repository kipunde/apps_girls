import 'package:flutter/material.dart';

import 'package:esrs_eqa_app/Enrollment/EnrollmentScreen.dart';
import 'package:esrs_eqa_app/Enrollment/ParticipantSectionWidget.dart';
import 'package:esrs_eqa_app/Enrollment/SchemeSectionWidget.dart';
import 'package:esrs_eqa_app/Enrollment/EnrollmentDocumentSectionWidget.dart';
import 'package:esrs_eqa_app/Enrollment/TestPointSectionWidget.dart';
import 'package:esrs_eqa_app/Models/EnrollmentModel.dart';
import 'package:esrs_eqa_app/Models/ListModel.dart';
import 'package:esrs_eqa_app/Models/MLServicesData.dart';
import 'package:esrs_eqa_app/Models/StepWidgetFlowModel.dart';
import 'package:esrs_eqa_app/SampleManagement/SamplesScreen.dart';
import 'package:esrs_eqa_app/Results/ResultScreen.dart';
import 'package:esrs_eqa_app/Reports/ReportScreen.dart';
import 'package:esrs_eqa_app/Subscribe/SubscribeScreen.dart';
import 'package:esrs_eqa_app/Configurations/ConfigurationScreen.dart';
import 'package:esrs_eqa_app/Screens/WalkThroughScreen.dart';
import 'package:esrs_eqa_app/Screens/SampleReceivingScreen.dart';
import 'package:esrs_eqa_app/Screens/HomeScreen.dart';
import 'package:esrs_eqa_app/Screens/AddTestResultScreen.dart';
import 'package:esrs_eqa_app/utils/EQAString.dart';
import 'package:esrs_eqa_app/Services/EQADataService.dart';
import 'Images.dart';

/// ---------------------------------------------------------------------------
/// Drawer items
/// ---------------------------------------------------------------------------
List<ListModel> getDrawerItems() {
  return [
    ListModel(name: 'Logout', widget: WalkThroughScreen()),
  ];
}

/// ---------------------------------------------------------------------------
/// Tracking status helper
/// ---------------------------------------------------------------------------
String trackingIdStatus(int statusId) {
  return 'Pending';
}

/// ---------------------------------------------------------------------------
/// Dashboard services
/// ---------------------------------------------------------------------------
List<MLServicesData> mlServiceDataList() {
  return [
    MLServicesData(
      title: s_subscribe,
      icon: Icons.home_work_outlined,
      image: ml_ic_dashClinicVisit!,
      widget: SubscribeScreen(),
    ),
    MLServicesData(
      title: s_enrollment,
      icon: Icons.home,
      image: ml_ic_dashHomeVisit,
      widget: EnrollmentScreen(),
    ),
    MLServicesData(
      title: s_samples,
      icon: Icons.video_call,
      image: ml_ic_dashVideoCons,
      widget: SamplesScreen(),
    ),
    MLServicesData(
      title: s_results,
      icon: Icons.local_hospital,
      image: ml_ic_dashDisease,
      widget: ResultScreen(),
    ),
    MLServicesData(
      title: s_reports,
      icon: Icons.health_and_safety,
      image: ml_ic_dashPharmacy,
      widget: ReportScreen(),
    ),
    MLServicesData(
      title: s_setting,
      icon: Icons.supervised_user_circle_outlined,
      image: ml_ic_dashCovid,
      //widget: ConfigurationScreen(),
      widget: HomeScreen(),
    ),
  ];
}

/// ---------------------------------------------------------------------------
/// ENROLLMENT FORM STEPS
/// ---------------------------------------------------------------------------
List<StepWidgetFlowModel> enrollmentFormSteps(EnrollmentModel enrollmentModel) {
  return [
    StepWidgetFlowModel(
      id: 1,
      title: s_a_participant,
      progress: 0.2,
      widget: ParticipantSectionWidget(enrollmentModel: enrollmentModel),
    ),
    StepWidgetFlowModel(
      id: 2,
      title: s_b_schemes,
      progress: 0.4,
      widget: SchemeSectionWidget(enrollmentModel: enrollmentModel),
    ),
    StepWidgetFlowModel(
      id: 3,
      title: s_c_test_points,
      progress: 0.6,
      widget: TestPointSectionWidget(enrollmentModel: enrollmentModel),
    ),
    StepWidgetFlowModel(
      id: 4,
      title: s_d_documents,
      progress: 0.8,
      widget: EnrollmentDocumentSectionWidget(enrollmentModel: enrollmentModel),
    ),
    StepWidgetFlowModel(
      id: 5,
      title: s_e_confirm,
      progress: 1.0,
      widget: EnrollmentConfirmSectionWidget(enrollmentModel: enrollmentModel),
    ),
  ];
}


/// ---------------------------------------------------------------------------
/// STEP 5 – CONFIRM & SUBMIT
/// ---------------------------------------------------------------------------
class EnrollmentConfirmSectionWidget extends StatelessWidget {
  final EnrollmentModel enrollmentModel;

  const EnrollmentConfirmSectionWidget({
    Key? key,
    required this.enrollmentModel,
  }) : super(key: key);

  void _submitEnrollment(BuildContext context) async {
  // Check if phone is empty
  if (enrollmentModel.contactName == null || enrollmentModel.contactName!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact name is required on the participant information!')),
    );
    return; // Stop submission
  }

    if (enrollmentModel.contactPosition == null || enrollmentModel.contactPosition!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Position is required on the participant information!')),
    );
    return; // Stop submission
  }
  if (enrollmentModel.phone == null || enrollmentModel.phone!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone Number is required on the participant information!')),
    );
    return; // Stop submission
  }
  if (enrollmentModel.email == null || enrollmentModel.email!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email Address is required on the participant information!')),
    );
    return; // Stop submission
  }

    // Validate at least one scheme selected
  if (enrollmentModel.selectedSchemes == null || enrollmentModel.selectedSchemes!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one scheme!')),
    );
    return;
  }

      // Validate at least one test point selected
  if (enrollmentModel.selectedTestPoints == null || enrollmentModel.selectedTestPoints!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one test point!')),
    );
    return;
  }

  final eqaService = EQADataService();

  try {
    bool success = await eqaService.submitEnrollment(enrollmentModel);

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment submitted successfully!')),
      );

      // Navigate safely: remove all previous routes and go to EnrollmentScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EnrollmentScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit enrollment.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting enrollment: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Safely handle back press: go to EnrollmentScreen without crash
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EnrollmentScreen()),
        );
        return false; // Prevent default pop
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Confirm Enrollment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please review all information before submitting.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Submit Enrollment'),
              onPressed: () => _submitEnrollment(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
