import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum BarcodeValueType {
  /// Unknown Barcode value types.
  unknown,

  /// Barcode value type for contact info.
  contactInfo,

  /// Barcode value type for email addresses.
  email,

  /// Barcode value type for ISBNs.
  isbn,

  /// Barcode value type for phone numbers.
  phone,

  /// Barcode value type for product codes.
  product,

  /// Barcode value type for SMS details.
  sms,

  /// Barcode value type for plain text.
  text,

  /// Barcode value type for URLs/bookmarks.
  url,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for geographic coordinates.
  geographicCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,
}

/// The type of email for [BarcodeEmail.type].
enum BarcodeEmailType {
  /// Unknown email type.
  unknown,

  /// Barcode work email type.
  work,

  /// Barcode home email type.
  home,
}

/// The type of phone number for [BarcodePhone.type].
enum BarcodePhoneType {
  /// Unknown phone type.
  unknown,

  /// Barcode work phone type.
  work,

  /// Barcode home phone type.
  home,

  /// Barcode fax phone type.
  fax,

  /// Barcode mobile phone type.
  mobile,
}

/// Wifi encryption type constants for [BarcodeWiFi.encryptionType].
enum BarcodeWiFiEncryptionType {
  /// Barcode unknown Wi-Fi encryption type.
  unknown,

  /// Barcode open Wi-Fi encryption type.
  open,

  /// Barcode WPA Wi-Fi encryption type.
  wpa,

  /// Barcode WEP Wi-Fi encryption type.
  wep,
}

/// Address type constants for [BarcodeAddress.type]
enum BarcodeAddressType {
  /// Barcode unknown address type.
  unknown,

  /// Barcode work address type.
  work,

  /// Barcode home address type.
  home,
}

/// Class containing supported barcode format constants for [BarcodeDetector].
///
/// Passed to [BarcodeDetectorOptions] to set which formats the detector should
/// detect.
///
/// Also, represents possible values for [Barcode.format].
class BarcodeFormat {
  const BarcodeFormat._(this.value);

  /// Barcode format constant representing the union of all supported formats.
  static const BarcodeFormat all = BarcodeFormat._(0xFFFF);

  /// Barcode format unknown to the current SDK.
  static const BarcodeFormat unknown = BarcodeFormat._(0);

  /// Barcode format constant for Code 128.
  static const BarcodeFormat code128 = BarcodeFormat._(0x0001);

  /// Barcode format constant for Code 39.
  static const BarcodeFormat code39 = BarcodeFormat._(0x0002);

  /// Barcode format constant for Code 93.
  static const BarcodeFormat code93 = BarcodeFormat._(0x0004);

  /// Barcode format constant for CodaBar.
  static const BarcodeFormat codabar = BarcodeFormat._(0x0008);

  /// Barcode format constant for Data Matrix.
  static const BarcodeFormat dataMatrix = BarcodeFormat._(0x0010);

  /// Barcode format constant for EAN-13.
  static const BarcodeFormat ean13 = BarcodeFormat._(0x0020);

  /// Barcode format constant for EAN-8.
  static const BarcodeFormat ean8 = BarcodeFormat._(0x0040);

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  static const BarcodeFormat itf = BarcodeFormat._(0x0080);

  /// Barcode format constant for QR Code.
  static const BarcodeFormat qrCode = BarcodeFormat._(0x0100);

  /// Barcode format constant for UPC-A.
  static const BarcodeFormat upca = BarcodeFormat._(0x0200);

  /// Barcode format constant for UPC-E.
  static const BarcodeFormat upce = BarcodeFormat._(0x0400);

  /// Barcode format constant for PDF-417.
  static const BarcodeFormat pdf417 = BarcodeFormat._(0x0800);

  /// Barcode format constant for AZTEC.
  static const BarcodeFormat aztec = BarcodeFormat._(0x1000);

  /// Raw BarcodeFormat value.
  final int value;

  BarcodeFormat operator |(BarcodeFormat other) =>
      BarcodeFormat._(value | other.value);
}

/// Detector for performing barcode scanning on an input image.
///
/// A barcode detector is created via
/// `barcodeDetector([BarcodeDetectorOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final BarcodeDetector barcodeDetector =
///     FirebaseVision.instance.barcodeDetector();
///
/// final List<Barcode> barcodes = await barcodeDetector.detectInImage(image);
/// ```
class BarcodeDetector {
  BarcodeDetector._(this.options, this._handle) : assert(options != null);

  /// The options for configuring this detector.
  final BarcodeDetectorOptions options;
  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects barcodes in the input image.
  Future<List<Barcode>> detectInImage(FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final List<dynamic> reply =
    await FirebaseVision.channel.invokeListMethod<dynamic>(
      'BarcodeDetector#detectInImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'barcodeFormats': options.barcodeFormats.value,
        },
      }..addAll(visionImage._serialize()),
    );

    final List<Barcode> barcodes = <Barcode>[];
    reply.forEach((dynamic barcode) {
      barcodes.add(Barcode._(barcode));
    });

    return barcodes;
  }

  /// Release resources used by this detector.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'BarcodeDetector#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Immutable options to configure [BarcodeDetector].
///
/// Sets which barcode formats the detector will detect. Defaults to
/// [BarcodeFormat.all].
///
/// Example usage:
/// ```dart
/// final BarcodeDetectorOptions options =
///     BarcodeDetectorOptions(barcodeFormats: BarcodeFormat.aztec | BarcodeFormat.ean8);
/// ```
class BarcodeDetectorOptions {
  const BarcodeDetectorOptions({this.barcodeFormats = BarcodeFormat.all});

  final BarcodeFormat barcodeFormats;
}

// TODO(bparrishMines): Normalize default string values. Some values return null on iOS while Android returns empty string.
/// Represents a single recognized barcode and its value.
class Barcode {
  Barcode._(Map<dynamic, dynamic> _data)
      : boundingBox = _data['left'] != null
      ? Rect.fromLTWH(
    _data['left'],
    _data['top'],
    _data['width'],
    _data['height'],
  )
      : null,
        rawValue = _data['rawValue'],
        displayValue = _data['displayValue'],
        format = BarcodeFormat._(_data['format']),
        _cornerPoints = _data['points'] == null
            ? null
            : _data['points']
            .map<Offset>((dynamic item) => Offset(
          item[0],
          item[1],
        ))
            .toList(),
        valueType = BarcodeValueType.values[_data['valueType']],
        email = _data['email'] == null ? null : BarcodeEmail._(_data['email']),
        phone = _data['phone'] == null ? null : BarcodePhone._(_data['phone']),
        sms = _data['sms'] == null ? null : BarcodeSMS._(_data['sms']),
        url = _data['url'] == null ? null : BarcodeURLBookmark._(_data['url']),
        wifi = _data['wifi'] == null ? null : BarcodeWiFi._(_data['wifi']),
        geoPoint = _data['geoPoint'] == null
            ? null
            : BarcodeGeoPoint._(_data['geoPoint']),
        contactInfo = _data['contactInfo'] == null
            ? null
            : BarcodeContactInfo._(_data['contactInfo']),
        calendarEvent = _data['calendarEvent'] == null
            ? null
            : BarcodeCalendarEvent._(_data['calendarEvent']),
        driverLicense = _data['driverLicense'] == null
            ? null
            : BarcodeDriverLicense._(_data['driverLicense']);

  final List<Offset> _cornerPoints;

  /// The bounding rectangle of the detected barcode.
  ///
  /// Could be null if the bounding rectangle can not be determined.
  final Rect boundingBox;

  /// Barcode value as it was encoded in the barcode.
  ///
  /// Structured values are not parsed, for example: 'MEBKM:TITLE:Google;URL://www.google.com;;'.
  ///
  /// Null if nothing found.
  final String rawValue;

  /// Barcode value in a user-friendly format.
  ///
  /// May omit some of the information encoded in the barcode.
  /// For example, if rawValue is 'MEBKM:TITLE:Google;URL://www.google.com;;',
  /// the displayValue might be '//www.google.com'.
  /// If valueType = [BarcodeValueType.text], this field will be equal to rawValue.
  ///
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Null if nothing found.
  final String displayValue;

  /// The barcode format, for example [BarcodeFormat.ean13].
  final BarcodeFormat format;

  /// The four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a rectangle.
  List<Offset> get cornerPoints => List<Offset>.from(_cornerPoints);

  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeValueType.text], [BarcodeValueType.product], [BarcodeValueType.url], etc.
  ///
  /// If the value structure cannot be parsed, [BarcodeValueType.text] will be returned.
  /// If the recognized structure type is not defined in your current version of SDK, [BarcodeValueType.unknown] will be returned.
  ///
  /// Note that the built-in parsers only recognize a few popular value structures.
  /// For your specific use case, you might want to directly consume rawValue
  /// and implement your own parsing logic.
  final BarcodeValueType valueType;

  /// Parsed email details. (set iff [valueType] is [BarcodeValueType.email]).
  final BarcodeEmail email;

  /// Parsed phone details. (set iff [valueType] is [BarcodeValueType.phone]).
  final BarcodePhone phone;

  /// Parsed SMS details. (set iff [valueType] is [BarcodeValueType.sms]).
  final BarcodeSMS sms;

  /// Parsed URL bookmark details. (set iff [valueType] is [BarcodeValueType.url]).
  final BarcodeURLBookmark url;

  /// Parsed WiFi AP details. (set iff [valueType] is [BarcodeValueType.wifi]).
  final BarcodeWiFi wifi;

  /// Parsed geo coordinates. (set iff [valueType] is [BarcodeValueType.geographicCoordinates]).
  final BarcodeGeoPoint geoPoint;

  /// Parsed contact details. (set iff [valueType] is [BarcodeValueType.contactInfo]).
  final BarcodeContactInfo contactInfo;

  /// Parsed calendar event details. (set iff [valueType] is [BarcodeValueType.calendarEvent]).
  final BarcodeCalendarEvent calendarEvent;

  /// Parsed driver's license details. (set iff [valueType] is [BarcodeValueType.driverLicense]).
  final BarcodeDriverLicense driverLicense;
}

/// An email message from a 'MAILTO:' or similar QRCode type.
class BarcodeEmail {
  BarcodeEmail._(Map<dynamic, dynamic> data)
      : type = BarcodeEmailType.values[data['type']],
        address = data['address'],
        body = data['body'],
        subject = data['subject'];

  /// The email's address.
  final String address;

  /// The email's body.
  final String body;

  /// The email's subject.
  final String subject;

  /// The type of the email.
  final BarcodeEmailType type;
}

/// Phone number info.
class BarcodePhone {
  BarcodePhone._(Map<dynamic, dynamic> data)
      : number = data['number'],
        type = BarcodePhoneType.values[data['type']];

  /// Phone number.
  final String number;

  /// Type of the phone number.
  ///
  /// See also:
  ///
  ///  * [BarcodePhoneType]
  final BarcodePhoneType type;
}

/// An sms message from an 'SMS:' or similar QRCode type.
class BarcodeSMS {
  BarcodeSMS._(Map<dynamic, dynamic> data)
      : message = data['message'],
        phoneNumber = data['phoneNumber'];

  /// An SMS message body.
  final String message;

  /// An SMS message phone number.
  final String phoneNumber;
}

/// A URL and title from a 'MEBKM:' or similar QRCode type.
class BarcodeURLBookmark {
  BarcodeURLBookmark._(Map<dynamic, dynamic> data)
      : title = data['title'],
        url = data['url'];

  /// A URL bookmark title.
  final String title;

  /// A URL bookmark url.
  final String url;
}

/// A wifi network parameters from a 'WIFI:' or similar QRCode type.
class BarcodeWiFi {
  BarcodeWiFi._(Map<dynamic, dynamic> data)
      : ssid = data['ssid'],
        password = data['password'],
        encryptionType =
        BarcodeWiFiEncryptionType.values[data['encryptionType']];

  /// A Wi-Fi access point SSID.
  final String ssid;

  /// A Wi-Fi access point password.
  final String password;

  /// The encryption type of the WIFI
  ///
  /// See all [BarcodeWiFiEncryptionType]
  final BarcodeWiFiEncryptionType encryptionType;
}

/// GPS coordinates from a 'GEO:' or similar QRCode type.
class BarcodeGeoPoint {
  BarcodeGeoPoint._(Map<dynamic, dynamic> data)
      : latitude = data['latitude'],
        longitude = data['longitude'];

  /// A location latitude.
  final double latitude;

  /// A location longitude.
  final double longitude;
}

/// A person's or organization's business card.
class BarcodeContactInfo {
  BarcodeContactInfo._(Map<dynamic, dynamic> data)
      : addresses = data['addresses'] == null
      ? null
      : List<BarcodeAddress>.unmodifiable(data['addresses']
      .map<BarcodeAddress>((dynamic item) => BarcodeAddress._(item))),
        emails = data['emails'] == null
            ? null
            : List<BarcodeEmail>.unmodifiable(data['emails']
            .map<BarcodeEmail>((dynamic item) => BarcodeEmail._(item))),
        name = data['name'] == null ? null : BarcodePersonName._(data['name']),
        phones = data['phones'] == null
            ? null
            : List<BarcodePhone>.unmodifiable(data['phones']
            .map<BarcodePhone>((dynamic item) => BarcodePhone._(item))),
        urls = data['urls'] == null
            ? null
            : List<String>.unmodifiable(
            data['urls'].map<String>((dynamic item) {
              final String s = item;
              return s;
            })),
        jobTitle = data['jobTitle'],
        organization = data['organization'];

  /// Contact person's addresses.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodeAddress> addresses;

  /// Contact person's emails.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodeEmail> emails;

  /// Contact person's name.
  final BarcodePersonName name;

  /// Contact person's phones.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodePhone> phones;

  /// Contact urls associated with this person.
  final List<String> urls;

  /// Contact person's title.
  final String jobTitle;

  /// Contact person's organization.
  final String organization;
}

/// An address.
class BarcodeAddress {
  BarcodeAddress._(Map<dynamic, dynamic> data)
      : addressLines = List<String>.unmodifiable(
      data['addressLines'].map<String>((dynamic item) {
        final String s = item;
        return s;
      })),
        type = BarcodeAddressType.values[data['type']];

  /// Formatted address, multiple lines when appropriate.
  ///
  /// This field always contains at least one line.
  final List<String> addressLines;

  /// Type of the address.
  ///
  /// See also:
  ///
  /// * [BarcodeAddressType]
  final BarcodeAddressType type;
}

/// A person's name, both formatted version and individual name components.
class BarcodePersonName {
  BarcodePersonName._(Map<dynamic, dynamic> data)
      : formattedName = data['formattedName'],
        first = data['first'],
        last = data['last'],
        middle = data['middle'],
        prefix = data['prefix'],
        pronunciation = data['pronunciation'],
        suffix = data['suffix'];

  /// The properly formatted name.
  final String formattedName;

  /// First name
  final String first;

  /// Last name
  final String last;

  /// Middle name
  final String middle;

  /// Prefix of the name
  final String prefix;

  /// Designates a text string to be set as the kana name in the phonebook. Used for Japanese contacts.
  final String pronunciation;

  /// Suffix of the person's name
  final String suffix;
}

/// DateTime data type used in calendar events.
class BarcodeCalendarEvent {
  BarcodeCalendarEvent._(Map<dynamic, dynamic> data)
      : eventDescription = data['eventDescription'],
        location = data['location'],
        organizer = data['organizer'],
        status = data['status'],
        summary = data['summary'],
        start = DateTime.parse(data['start']),
        end = DateTime.parse(data['end']);

  /// The description of the calendar event.
  final String eventDescription;

  /// The location of the calendar event.
  final String location;

  /// The organizer of the calendar event.
  final String organizer;

  /// The status of the calendar event.
  final String status;

  /// The summary of the calendar event.
  final String summary;

  /// The start date time of the calendar event.
  final DateTime start;

  /// The end date time of the calendar event.
  final DateTime end;
}

/// A driver license or ID card.
class BarcodeDriverLicense {
  BarcodeDriverLicense._(Map<dynamic, dynamic> data)
      : firstName = data['firstName'],
        middleName = data['middleName'],
        lastName = data['lastName'],
        gender = data['gender'],
        addressCity = data['addressCity'],
        addressState = data['addressState'],
        addressStreet = data['addressStreet'],
        addressZip = data['addressZip'],
        birthDate = data['birthDate'],
        documentType = data['documentType'],
        licenseNumber = data['licenseNumber'],
        expiryDate = data['expiryDate'],
        issuingDate = data['issuingDate'],
        issuingCountry = data['issuingCountry'];

  /// Holder's first name.
  final String firstName;

  /// Holder's middle name.
  final String middleName;

  /// Holder's last name.
  final String lastName;

  /// Holder's gender. 1 - male, 2 - female.
  final String gender;

  /// City of holder's address.
  final String addressCity;

  /// State of holder's address.
  final String addressState;

  /// Holder's street address.
  final String addressStreet;

  /// Zip code of holder's address.
  final String addressZip;

  /// Birth date of the holder.
  final String birthDate;

  /// "DL" for driver licenses, "ID" for ID cards.
  final String documentType;

  /// Driver license ID number.
  final String licenseNumber;

  /// Expiry date of the license.
  final String expiryDate;

  /// Issue date of the license.
  ///
  /// The date format depends on the issuing country. MMDDYYYY for the US, YYYYMMDD for Canada.
  final String issuingDate;

  /// Country in which DL/ID was issued. US = "USA", Canada = "CAN".
  final String issuingCountry;
}

enum FaceDetectorMode { accurate, fast }

/// Available face landmarks detected by [FaceDetector].
enum FaceLandmarkType {
  bottomMouth,
  leftCheek,
  leftEar,
  leftEye,
  leftMouth,
  noseBase,
  rightCheek,
  rightEar,
  rightEye,
  rightMouth,
}

/// Available face contour types detected by [FaceDetector].
enum FaceContourType {
  allPoints,
  face,
  leftEye,
  leftEyebrowBottom,
  leftEyebrowTop,
  lowerLipBottom,
  lowerLipTop,
  noseBottom,
  noseBridge,
  rightEye,
  rightEyebrowBottom,
  rightEyebrowTop,
  upperLipBottom,
  upperLipTop
}

/// Detector for detecting faces in an input image.
///
/// A face detector is created via
/// `faceDetector([FaceDetectorOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
///
/// final List<Faces> faces = await faceDetector.processImage(image);
/// ```
class FaceDetector {
  FaceDetector._(this.options, this._handle) : assert(options != null);

  /// The options for the face detector.
  final FaceDetectorOptions options;
  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects faces in the input image.
  Future<List<Face>> processImage(FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final List<dynamic> reply =
    await FirebaseVision.channel.invokeListMethod<dynamic>(
      'FaceDetector#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'enableClassification': options.enableClassification,
          'enableLandmarks': options.enableLandmarks,
          'enableContours': options.enableContours,
          'enableTracking': options.enableTracking,
          'minFaceSize': options.minFaceSize,
          'mode': _enumToString(options.mode),
        },
      }..addAll(visionImage._serialize()),
    );

    final List<Face> faces = <Face>[];
    for (dynamic data in reply) {
      faces.add(Face._(data));
    }

    return faces;
  }

  /// Release resources used by this detector.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'FaceDetector#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Immutable options for configuring features of [FaceDetector].
///
/// Used to configure features such as classification, face tracking, speed,
/// etc.
class FaceDetectorOptions {
  /// Constructor for [FaceDetectorOptions].
  ///
  /// The parameter minFaceValue must be between 0.0 and 1.0, inclusive.
  const FaceDetectorOptions({
    this.enableClassification = false,
    this.enableLandmarks = false,
    this.enableContours = false,
    this.enableTracking = false,
    this.minFaceSize = 0.1,
    this.mode = FaceDetectorMode.fast,
  })  : assert(minFaceSize >= 0.0),
        assert(minFaceSize <= 1.0);

  /// Whether to run additional classifiers for characterizing attributes.
  ///
  /// E.g. "smiling" and "eyes open".
  final bool enableClassification;

  /// Whether to detect [FaceLandmark]s.
  final bool enableLandmarks;

  /// Whether to detect [FaceContour]s.
  final bool enableContours;

  /// Whether to enable face tracking.
  ///
  /// If enabled, the detector will maintain a consistent ID for each face when
  /// processing consecutive frames.
  final bool enableTracking;

  /// The smallest desired face size.
  ///
  /// Expressed as a proportion of the width of the head to the image width.
  ///
  /// Must be a value between 0.0 and 1.0.
  final double minFaceSize;

  /// Option for controlling additional accuracy / speed trade-offs.
  final FaceDetectorMode mode;
}

/// Represents a face detected by [FaceDetector].
class Face {
  Face._(dynamic data)
      : boundingBox = Rect.fromLTWH(
    data['left'],
    data['top'],
    data['width'],
    data['height'],
  ),
        headEulerAngleY = data['headEulerAngleY'],
        headEulerAngleZ = data['headEulerAngleZ'],
        leftEyeOpenProbability = data['leftEyeOpenProbability'],
        rightEyeOpenProbability = data['rightEyeOpenProbability'],
        smilingProbability = data['smilingProbability'],
        trackingId = data['trackingId'],
        _landmarks = Map<FaceLandmarkType, FaceLandmark>.fromIterables(
            FaceLandmarkType.values,
            FaceLandmarkType.values.map((FaceLandmarkType type) {
              final List<dynamic> pos = data['landmarks'][_enumToString(type)];
              return (pos == null)
                  ? null
                  : FaceLandmark._(
                type,
                Offset(pos[0], pos[1]),
              );
            })),
        _contours = Map<FaceContourType, FaceContour>.fromIterables(
            FaceContourType.values,
            FaceContourType.values.map((FaceContourType type) {
              /// added empty map to pass the tests
              final List<dynamic> arr =
              (data['contours'] ?? <String, dynamic>{})[_enumToString(type)];
              return (arr == null)
                  ? null
                  : FaceContour._(
                type,
                arr
                    .map<Offset>((dynamic pos) => Offset(pos[0], pos[1]))
                    .toList(),
              );
            }));

  final Map<FaceLandmarkType, FaceLandmark> _landmarks;
  final Map<FaceContourType, FaceContour> _contours;

  /// The axis-aligned bounding rectangle of the detected face.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Rect boundingBox;

  /// The rotation of the face about the vertical axis of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Y angle is turned to the camera's right and
  /// to its left.
  ///
  /// The Euler Y angle is guaranteed only when using the "accurate" mode
  /// setting of the face detector (as opposed to the "fast" mode setting, which
  /// takes some shortcuts to make detection faster).
  final double headEulerAngleY;

  /// The rotation of the face about the axis pointing out of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Z angle is rotated counter-clockwise relative
  /// to the camera.
  ///
  /// ML Kit always reports the Euler Z angle of a detected face.
  final double headEulerAngleZ;

  /// Probability that the face's left eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double leftEyeOpenProbability;

  /// Probability that the face's right eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double rightEyeOpenProbability;

  /// Probability that the face is smiling.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double smilingProbability;

  /// The tracking ID if the tracking is enabled.
  ///
  /// Null if tracking was not enabled.
  final int trackingId;

  /// Gets the landmark based on the provided [FaceLandmarkType].
  ///
  /// Null if landmark was not detected.
  FaceLandmark getLandmark(FaceLandmarkType landmark) => _landmarks[landmark];

  /// Gets the contour based on the provided [FaceContourType].
  ///
  /// Null if contour was not detected.
  FaceContour getContour(FaceContourType contour) => _contours[contour];
}

/// Represent a face landmark.
///
/// A landmark is a point on a detected face, such as an eye, nose, or mouth.
class FaceLandmark {
  FaceLandmark._(this.type, this.position);

  /// The [FaceLandmarkType] of this landmark.
  final FaceLandmarkType type;

  /// Gets a 2D point for landmark position.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Offset position;
}

/// Represent a face contour.
///
/// Contours of facial features.
class FaceContour {
  FaceContour._(this.type, this.positionsList);

  /// The [FaceContourType] of this contour.
  final FaceContourType type;

  /// Gets a 2D point [List] for contour positions.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final List<Offset> positionsList;
}

enum _ImageType { file, bytes }

/// Indicates the image rotation.
///
/// Rotation is counter-clockwise.
enum ImageRotation { rotation0, rotation90, rotation180, rotation270 }

/// Indicates whether a model is ran on device or in the cloud.
enum ModelType { onDevice, cloud }

/// The Firebase machine learning vision API.
///
/// You can get an instance by calling [FirebaseVision.instance] and then get
/// a detector from the instance:
///
/// ```dart
/// TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
/// ```
class FirebaseVision {
  FirebaseVision._();

  @visibleForTesting
  static const MethodChannel channel =
  MethodChannel('plugins.flutter.io/firebase_ml_vision');

  @visibleForTesting
  static int nextHandle = 0;

  /// Singleton of [FirebaseVision].
  ///
  /// Use this get an instance of a detector:
  ///
  /// ```dart
  /// TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  /// ```
  static final FirebaseVision instance = FirebaseVision._();

  /// Creates an instance of [BarcodeDetector].
  BarcodeDetector barcodeDetector([BarcodeDetectorOptions options]) {
    return BarcodeDetector._(
      options ?? const BarcodeDetectorOptions(),
      nextHandle++,
    );
  }

  /// Creates an instance of [FaceDetector].
  FaceDetector faceDetector([FaceDetectorOptions options]) {
    return FaceDetector._(
      options ?? const FaceDetectorOptions(),
      nextHandle++,
    );
  }

  /// Creates an on device instance of [ImageLabeler].
  ImageLabeler imageLabeler([ImageLabelerOptions options]) {
    return ImageLabeler._(
      options: options ?? const ImageLabelerOptions(),
      modelType: ModelType.onDevice,
      handle: nextHandle++,
    );
  }

  /// Creates an instance of [TextRecognizer].
  TextRecognizer textRecognizer() {
    return TextRecognizer._(
      modelType: ModelType.onDevice,
      handle: nextHandle++,
    );
  }

  /// Creates a cloud instance of [ImageLabeler].
  ImageLabeler cloudImageLabeler([CloudImageLabelerOptions options]) {
    return ImageLabeler._(
      options: options ?? const CloudImageLabelerOptions(),
      modelType: ModelType.cloud,
      handle: nextHandle++,
    );
  }

  /// Creates a cloud instance of [TextRecognizer].
  TextRecognizer cloudTextRecognizer() {
    return TextRecognizer._(
      modelType: ModelType.cloud,
      handle: nextHandle++,
    );
  }
}

/// Represents an image object used for both on-device and cloud API detectors.
///
/// Create an instance by calling one of the factory constructors.
class FirebaseVisionImage {
  FirebaseVisionImage._({
    @required _ImageType type,
    FirebaseVisionImageMetadata metadata,
    File imageFile,
    Uint8List bytes,
  })  : _imageFile = imageFile,
        _metadata = metadata,
        _bytes = bytes,
        _type = type;

  /// Construct a [FirebaseVisionImage] from a file.
  factory FirebaseVisionImage.fromFile(File imageFile) {
    assert(imageFile != null);
    return FirebaseVisionImage._(
      type: _ImageType.file,
      imageFile: imageFile,
    );
  }

  /// Construct a [FirebaseVisionImage] from a file path.
  factory FirebaseVisionImage.fromFilePath(String imagePath) {
    assert(imagePath != null);
    return FirebaseVisionImage._(
      type: _ImageType.file,
      imageFile: File(imagePath),
    );
  }

  /// Construct a [FirebaseVisionImage] from a list of bytes.
  ///
  /// On Android, expects `android.graphics.ImageFormat.NV21` format. Note:
  /// Concatenating the planes of `android.graphics.ImageFormat.YUV_420_888`
  /// into a single plane, converts it to `android.graphics.ImageFormat.NV21`.
  ///
  /// On iOS, expects `kCVPixelFormatType_32BGRA` format. However, this should
  /// work with most formats from `kCVPixelFormatType_*`.
  factory FirebaseVisionImage.fromBytes(
      Uint8List bytes,
      FirebaseVisionImageMetadata metadata,
      ) {
    assert(bytes != null);
    assert(metadata != null);
    return FirebaseVisionImage._(
      type: _ImageType.bytes,
      bytes: bytes,
      metadata: metadata,
    );
  }

  final Uint8List _bytes;
  final File _imageFile;
  final FirebaseVisionImageMetadata _metadata;
  final _ImageType _type;

  Map<String, dynamic> _serialize() => <String, dynamic>{
    'type': _enumToString(_type),
    'bytes': _bytes,
    'path': _imageFile?.path,
    'metadata': _type == _ImageType.bytes ? _metadata._serialize() : null,
  };
}

/// Plane attributes to create the image buffer on iOS.
///
/// When using iOS, [bytesPerRow], [height], and [width] throw [AssertionError]
/// if `null`.
class FirebaseVisionImagePlaneMetadata {
  FirebaseVisionImagePlaneMetadata({
    @required this.bytesPerRow,
    @required this.height,
    @required this.width,
  })  : assert(defaultTargetPlatform == TargetPlatform.iOS
      ? bytesPerRow != null
      : true),
        assert(defaultTargetPlatform == TargetPlatform.iOS
            ? height != null
            : true),
        assert(
        defaultTargetPlatform == TargetPlatform.iOS ? width != null : true);

  /// The row stride for this color plane, in bytes.
  final int bytesPerRow;

  /// Height of the pixel buffer on iOS.
  final int height;

  /// Width of the pixel buffer on iOS.
  final int width;

  Map<String, dynamic> _serialize() => <String, dynamic>{
    'bytesPerRow': bytesPerRow,
    'height': height,
    'width': width,
  };
}

/// Image metadata used by [FirebaseVision] detectors.
///
/// [rotation] defaults to [ImageRotation.rotation0]. Currently only rotates on
/// Android.
///
/// When using iOS, [rawFormat] and [planeData] throw [AssertionError] if
/// `null`.
class FirebaseVisionImageMetadata {
  FirebaseVisionImageMetadata({
    @required this.size,
    @required this.rawFormat,
    @required this.planeData,
    this.rotation = ImageRotation.rotation0,
  })  : assert(size != null),
        assert(defaultTargetPlatform == TargetPlatform.iOS
            ? rawFormat != null
            : true),
        assert(defaultTargetPlatform == TargetPlatform.iOS
            ? planeData != null
            : true),
        assert(defaultTargetPlatform == TargetPlatform.iOS
            ? planeData.isNotEmpty
            : true);

  /// Size of the image in pixels.
  final Size size;

  /// Rotation of the image for Android.
  ///
  /// Not currently used on iOS.
  final ImageRotation rotation;

  /// Raw version of the format from the iOS platform.
  ///
  /// Since iOS can use any planar format, this format will be used to create
  /// the image buffer on iOS.
  ///
  /// On iOS, this is a `FourCharCode` constant from Pixel Format Identifiers.
  /// See https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers?language=objc
  ///
  /// Not used on Android.
  final dynamic rawFormat;

  /// The plane attributes to create the image buffer on iOS.
  ///
  /// Not used on Android.
  final List<FirebaseVisionImagePlaneMetadata> planeData;

  int _imageRotationToInt(ImageRotation rotation) {
    switch (rotation) {
      case ImageRotation.rotation90:
        return 90;
      case ImageRotation.rotation180:
        return 180;
      case ImageRotation.rotation270:
        return 270;
      default:
        assert(rotation == ImageRotation.rotation0);
        return 0;
    }
  }

  Map<String, dynamic> _serialize() => <String, dynamic>{
    'width': size.width,
    'height': size.height,
    'rotation': _imageRotationToInt(rotation),
    'rawFormat': rawFormat,
    'planeData': planeData
        .map((FirebaseVisionImagePlaneMetadata plane) => plane._serialize())
        .toList(),
  };
}

String _enumToString(dynamic enumValue) {
  final String enumString = enumValue.toString();
  return enumString.substring(enumString.indexOf('.') + 1);
}

class ImageLabeler {
  ImageLabeler._({
    @required dynamic options,
    @required this.modelType,
    @required int handle,
  })  : _options = options,
        _handle = handle,
        assert(options != null),
        assert(modelType != null);

  /// Indicates whether this labeler is ran on device or in the cloud.
  final ModelType modelType;

  // Should be of type ImageLabelerOptions or CloudImageLabelerOptions.
  final dynamic _options;
  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Finds entities in the input image.
  Future<List<ImageLabel>> processImage(FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final List<dynamic> reply =
    await FirebaseVision.channel.invokeListMethod<dynamic>(
      'ImageLabeler#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'modelType': _enumToString(modelType),
          'confidenceThreshold': _options.confidenceThreshold,
        },
      }..addAll(visionImage._serialize()),
    );

    final List<ImageLabel> labels = <ImageLabel>[];
    for (dynamic data in reply) {
      labels.add(ImageLabel._(data));
    }

    return labels;
  }

  /// Release resources used by this labeler.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'ImageLabeler#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Options for on device image labeler.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class ImageLabelerOptions {
  /// Constructor for [ImageLabelerOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const ImageLabelerOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Options for cloud image labeler.
///
/// Confidence threshold could be provided for the label detection. For example,
/// if the confidence threshold is set to 0.7, only labels with
/// confidence >= 0.7 would be returned. The default threshold is 0.5.
class CloudImageLabelerOptions {
  /// Constructor for [CloudImageLabelerOptions].
  ///
  /// Confidence threshold could be provided for the label detection.
  /// For example, if the confidence threshold is set to 0.7, only labels with
  /// confidence >= 0.7 would be returned. The default threshold is 0.5.
  const CloudImageLabelerOptions({this.confidenceThreshold = 0.5})
      : assert(confidenceThreshold >= 0.0),
        assert(confidenceThreshold <= 1.0);

  /// The minimum confidence threshold of labels to be detected.
  ///
  /// Required to be in range [0.0, 1.0].
  final double confidenceThreshold;
}

/// Represents an entity label detected by [ImageLabeler] and [CloudImageLabeler].
class ImageLabel {
  ImageLabel._(dynamic data)
      : confidence = data['confidence'],
        entityId = data['entityId'],
        text = data['text'];

  /// The overall confidence of the result. Range [0.0, 1.0].
  final double confidence;

  /// The opaque entity ID.
  ///
  /// IDs are available in Google Knowledge Graph Search API
  /// https://developers.google.com/knowledge-graph/
  final String entityId;

  /// A detected label from the given image.
  ///
  /// The label returned here is in English only. The end developer should use
  /// [entityId] to retrieve unique id.
  final String text;
}

class TextRecognizer {
  TextRecognizer._({
    @required this.modelType,
    @required int handle,
  })  : _handle = handle,
        assert(modelType != null);

  final ModelType modelType;

  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects [VisionText] from a [FirebaseVisionImage].
  Future<VisionText> processImage(FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final Map<String, dynamic> reply =
    await FirebaseVision.channel.invokeMapMethod<String, dynamic>(
      'TextRecognizer#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'modelType': _enumToString(modelType),
        },
      }..addAll(visionImage._serialize()),
    );

    return VisionText._(reply);
  }

  /// Release resources used by this recognizer.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'TextRecognizer#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Recognized text in an image.
class VisionText {
  VisionText._(Map<String, dynamic> data)
      : text = data['text'],
        blocks = List<TextBlock>.unmodifiable(data['blocks']
            .map<TextBlock>((dynamic block) => TextBlock._(block)));

  /// String representation of the recognized text.
  final String text;

  /// All recognized text broken down into individual blocks/paragraphs.
  final List<TextBlock> blocks;
}

/// Detected language from text recognition.
class RecognizedLanguage {
  RecognizedLanguage._(dynamic data) : languageCode = data['languageCode'];

  /// The BCP-47 language code, such as, en-US or sr-Latn. For more information,
  /// see http://www.unicode.org/reports/tr35/#Unicode_locale_identifier.
  final String languageCode;
}

/// Abstract class representing dimensions of recognized text in an image.
abstract class TextContainer {
  TextContainer._(Map<dynamic, dynamic> data)
      : boundingBox = data['left'] != null
      ? Rect.fromLTWH(
    data['left'],
    data['top'],
    data['width'],
    data['height'],
  )
      : null,
        confidence = data['confidence'],
        cornerPoints = List<Offset>.unmodifiable(
            data['points'].map<Offset>((dynamic point) => Offset(
              point[0],
              point[1],
            ))),
        recognizedLanguages = List<RecognizedLanguage>.unmodifiable(
            data['recognizedLanguages'].map<RecognizedLanguage>(
                    (dynamic language) => RecognizedLanguage._(language))),
        text = data['text'];

  /// Axis-aligned bounding rectangle of the detected text.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  ///
  /// Could be null even if text is found.
  final Rect boundingBox;

  /// The confidence of the recognized text block.
  ///
  /// The value is null for all text recognizers except for cloud text
  /// recognizers.
  final double confidence;

  /// The four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a
  /// rectangle. Parts of the region could be outside of the image.
  ///
  /// Could be empty even if text is found.
  final List<Offset> cornerPoints;

  /// All detected languages from recognized text.
  ///
  /// On-device text recognizers only detect Latin-based languages, while cloud
  /// text recognizers can detect multiple languages. If no languages are
  /// recognized, the list is empty.
  final List<RecognizedLanguage> recognizedLanguages;

  /// The recognized text as a string.
  ///
  /// Returned in reading order for the language. For Latin, this is top to
  /// bottom within a Block, and left-to-right within a Line.
  final String text;
}

/// A block of text (think of it as a paragraph) as deemed by the OCR engine.
class TextBlock extends TextContainer {
  TextBlock._(Map<dynamic, dynamic> block)
      : lines = List<TextLine>.unmodifiable(
      block['lines'].map<TextLine>((dynamic line) => TextLine._(line))),
        super._(block);

  /// The contents of the text block, broken down into individual lines.
  final List<TextLine> lines;
}

/// Represents a line of text.
class TextLine extends TextContainer {
  TextLine._(Map<dynamic, dynamic> line)
      : elements = List<TextElement>.unmodifiable(line['elements']
      .map<TextElement>((dynamic element) => TextElement._(element))),
        super._(line);

  /// The contents of this line, broken down into individual elements.
  final List<TextElement> elements;
}

/// Roughly equivalent to a space-separated "word."
///
/// The API separates elements into words in most Latin languages, but could
/// separate by characters in others.
///
/// If a word is split between two lines by a hyphen, each part is encoded as a
/// separate element.
class TextElement extends TextContainer {
  TextElement._(Map<dynamic, dynamic> element) : super._(element);
}
