
package io.flutter.plugins;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.example.wuriproject.R;
import com.suprema.BioMiniFactory;
import com.suprema.CaptureResponder;
import com.suprema.IBioMiniDevice;
import com.suprema.IUsbEventHandler;

import com.telpo.tps550.api.fingerprint.FingerPrint;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

public class FingerpintHelper  extends AppCompatActivity implements View.OnClickListener {

    //Flag.
    public static final boolean mbUsbExternalUSBManager = true;
    private static final String ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION";
    private static final int REQUEST_CODE_CAPTURE_PHOTO = 1;
    private static final int REQUEST_SELECT_PHOTO = 2;
    private   String photoString;
    private UsbManager mUsbManager = null;
    private PendingIntent mPermissionIntent = null;
    private int doigt;


    boolean pouceDroitPris = false;
    private Button btnSelectPhoto;
    private byte [] photoBytes;

    private LinearLayout naf;
    private Uri photoUri;
    //


    private IBioMiniDevice.CaptureOption mCaptureOptionDefault = new IBioMiniDevice.CaptureOption();
    private CaptureResponder mCaptureResponseDefault = new CaptureResponder() {
        @Override
        public boolean onCaptureEx(final Object context,
                                   final Bitmap capturedImage,

                                   final IBioMiniDevice.TemplateData capturedTemplate,
                                   final IBioMiniDevice.FingerState fingerState) {

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (capturedImage != null) {
                        ImageView iv1 = null;
                        if(doigt==1){
                            iv1 = pouceDroit;
                            pouceDroitPris=true;
                        }


                        if (iv1 != null) {
                            System.out.println("<===========================================================> set1");
                            iv1.setImageBitmap(capturedImage);
                            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                                    capturedImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
                                    byte[] byteArray = stream.toByteArray();
                                    String base64 = Base64.encodeToString(byteArray, Base64.NO_WRAP);

                                    // 👉 Renvoyer à Flutter
                                    Intent returnIntent = new Intent();
                                    returnIntent.putExtra("fingerprint_base64", base64);
                                    setResult(RESULT_OK, returnIntent);
                                    finish();
                                }
                            }, 3000);
                        }

                    }
                }
            });

            return true;
        }

        @Override
        public void onCaptureError(Object contest, int errorCode, String error) {
            //log_i("onCaptureError : " + error);
            //if( errorCode != IBioMiniDevice.ErrorCode.OK.value())                 printState(getResources().getText(R.string.capture_single_fail) + "("+error+")");
        }
    };
    private CaptureResponder mCaptureResponsePrev = new CaptureResponder() {
        @Override
        public boolean onCaptureEx(final Object context, final Bitmap capturedImage,
                                   final IBioMiniDevice.TemplateData capturedTemplate,
                                   final IBioMiniDevice.FingerState fingerState) {
            /*
            log_i(TAG,"CaptureResponsePrev",
                    String.format(
                            Locale.ENGLISH ,
                            "captureTemplate.size (%d) , fingerState(%s)" ,
                            capturedTemplate== null? 0 : capturedTemplate.data.length,
                            String.valueOf(fingerState.isFingerExist))
            );
             */
            //printState(getResources().getText(R.string.start_capture_ok));
            byte[] pImage_raw = null;
            if ((mCurrentDevice != null && (pImage_raw = mCurrentDevice.getCaptureImageAsRAW_8()) != null)) {
                /*
                log_i(TAG,"CaptureResponsePrev ",
                        String.format(Locale.ENGLISH, "pImage (%d) , FP Quality(%d)", pImage_raw.length , mCurrentDevice.getFPQuality(pImage_raw, mCurrentDevice.getImageWidth(), mCurrentDevice.getImageHeight(), 2))
                );
                 */
            }
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (capturedImage != null) {
                        ImageView iv = (ImageView) findViewById(R.id.ajoutassure_step4_droite_pouce);
                        if (iv != null) {
                            iv.setImageBitmap(capturedImage);
                        }
                    }
                }
            });
            // Quitter FingerpintActivity
            return true;
        }

        @Override
        public void onCaptureError(Object context, int errorCode, String error) {
            //log_i("onCaptureError : " + error);
            //log_i(((IBioMiniDevice)context).popPerformancelog_i());
            //if( errorCode != IBioMiniDevice.ErrorCode.OK.value()) printState(getResources().getText(R.string.start_capture_fail));
        }
    };


    private static BioMiniFactory mBioMiniFactory = null;
    public static final int REQUEST_WRITE_PERMISSION = 786;
    public IBioMiniDevice mCurrentDevice = null;
    private FingerpintHelper mainContext;

    public final static String TAG = "CNAMU MOBILE STEP 4";

    private ImageButton pouceDroit, indexDroit, majeurDroit, annulaireDroit, auriculaireDroit, pouceGauche, indexGauche, majeurGauche, annulaireGauche, auriculaireGauche;
    private ImageButton ibPhoto;
    private Button btnSuivant, btnPrecedent;
    private LinearLayout commentaire;
    private SharedPreferences sp;
    private  Uri photo;

    private String categorieAssure="";

    private String typeAssures="";
    String token="";


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_fingerpint);
        mCaptureOptionDefault.frameRate = IBioMiniDevice.FrameRate.SHIGH;
        mainContext = this;
        FingerPrint.fingerPrintPower(1);
        restartBioMini();



        pouceDroit = (ImageButton) findViewById(R.id.ajoutassure_step4_droite_pouce);


        pouceDroit.setOnClickListener(this);

        //////////////////////////////////////////////////////////////////////////////////////




        if (mBioMiniFactory != null) {
            mBioMiniFactory.close();
        }




    }




    private static final String ALLOWED_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";



    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    @Override
    protected void onResume() {
        super.onResume();
        FingerPrint.fingerPrintPower(1);
        mPermissionIntent = PendingIntent.getBroadcast(this,0,new Intent(ACTION_USB_PERMISSION), 0);
        IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
        registerReceiver(mUsbReceiver, filter);
    }

    private final BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {

        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
//            log_i(TAG, "BroadcastReceiver mUsbReceiver onReceive");
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    UsbDevice device = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        if (device != null) {
                            if (mBioMiniFactory == null) return;
                            mBioMiniFactory.addDevice(device);
                            //log_i(TAG, "permission granted for device"+ device);
                            //log_i(String.format(Locale.ENGLISH ,"Initialized device count- BioMiniFactory (%d)" , mBioMiniFactory.getDeviceCount() ));
                        }
                    } else {
                        //log_i(TAG, "permission denied for device"+ device);
                    }
                }
            }
        }
    };

    public void checkDevice() {
        if (mUsbManager == null) return;
        //log_i("checkDevice");
        HashMap<String, UsbDevice> deviceList = mUsbManager.getDeviceList();
        Iterator<UsbDevice> deviceIter = deviceList.values().iterator();
        while (deviceIter.hasNext()) {
            UsbDevice _device = deviceIter.next();
            if (_device.getVendorId() == 0x16d1) {
                //Suprema vendor ID
                mUsbManager.requestPermission(_device, mPermissionIntent);
            } else {
            }
        }

    }

    void handleDevChange(IUsbEventHandler.DeviceChangeEvent event, Object dev) {
        if (event == IUsbEventHandler.DeviceChangeEvent.DEVICE_ATTACHED && mCurrentDevice == null) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    int cnt = 0;
                    while (mBioMiniFactory == null && cnt < 20) {
                        SystemClock.sleep(1000);
                        cnt++;
                    }
                    if (mBioMiniFactory != null) {
                        mCurrentDevice = mBioMiniFactory.getDevice(0);
                        //printState(getResources().getText(R.string.device_attached));
//                    Log.i(TAG, "mCurrentDevice attached : " + mCurrentDevice);
                        if (mCurrentDevice != null) {
//                        Log.i(TAG,"DeviceName : " + mCurrentDevice.getDeviceInfo().deviceName);
//                        Log.i(TAG,"         SN : " + mCurrentDevice.getDeviceInfo().deviceSN);
//                        Log.i(TAG,"SDK version : " + mCurrentDevice.getDeviceInfo().versionSDK);
                        }
                    }
                }
            }).start();
        } else if (mCurrentDevice != null && event == IUsbEventHandler.DeviceChangeEvent.DEVICE_DETACHED && mCurrentDevice.isEqual(dev)) {
            //printState(getResources().getText(R.string.device_detached));
            //log_i(TAG, "mCurrentDevice removed : " + mCurrentDevice);
            mCurrentDevice = null;
        }
    }

    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    void restartBioMini() {
        //log_i("","dans restartBioMini");
        if(mBioMiniFactory != null) {
            //mBioMiniFactory.close();
            //FingerPrint.fingerPrintPower(0);
        }
        if (mbUsbExternalUSBManager) {
            //log_i("","mbUsbExternalUSBManager = true");
            mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
            mBioMiniFactory = new BioMiniFactory(mainContext, mUsbManager) {
                @Override
                public void onDeviceChange(DeviceChangeEvent event, Object dev) {
                    //log_i(TAG,"----------------------------------------");
                    //log_i(TAG,"onDeviceChange : " + event + " using external usb-manager");
                    //log_i(TAG,"----------------------------------------");
                    handleDevChange(event, dev);
                }
            };
            //log_i("",mBioMiniFactory.toString()+"; nb="+mBioMiniFactory.getDeviceCount());
            //
            mPermissionIntent = PendingIntent.getBroadcast(this, 0, new Intent(ACTION_USB_PERMISSION), 0);
            IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
            registerReceiver(mUsbReceiver, filter);
            checkDevice();
        } else {
            //log_i("","mbUsbExternalUSBManager = false");
            mBioMiniFactory = new BioMiniFactory(getApplicationContext()) {
                @Override
                public void onDeviceChange(DeviceChangeEvent event, Object dev) {
                    //log_i(TAG,"----------------------------------------");
                    //log_i(TAG,"onDeviceChange : " + event);
                    //log_i(TAG,"----------------------------------------");
                    handleDevChange(event, dev);
                }
            };
            //log_i("",mBioMiniFactory.toString()+"; nb="+mBioMiniFactory.getDeviceCount());
        }
        //mBioMiniFactory.setTransferMode(IBioMiniDevice.TransferMode.MODE2);
    }

    @Override
    protected void onDestroy() {
        if (mBioMiniFactory != null) {

            //  mBioMiniFactory.close();

            mBioMiniFactory = null;
        }
        if (mbUsbExternalUSBManager) {
            unregisterReceiver(mUsbReceiver);
        }
        FingerPrint.fingerPrintPower(1);
        super.onDestroy();

    }

    private void requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE}, REQUEST_WRITE_PERMISSION);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_WRITE_PERMISSION && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            //log_i(TAG,"permission granted");
        }
    }

    @Override
    public void onPostCreate(Bundle savedInstanceState) {
        requestPermission();
        super.onPostCreate(savedInstanceState);
    }

    public void log_i(String TAG, String txt) {
        Toast.makeText(getApplicationContext(), txt, Toast.LENGTH_SHORT).show();
    }

    private File createTempImageFile() {
        // Créer un fichier temporaire pour enregistrer l'image capturée
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        try {
            return File.createTempFile(imageFileName, ".jpg", storageDir);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Bitmap decodeSampledBitmap(byte[] photoBytes, int reqWidth, int reqHeight) {
        // Décode l'image avec les dimensions requises pour réduire la consommation de mémoire
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeByteArray(photoBytes, 0, photoBytes.length, options);
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
        options.inJustDecodeBounds = false;
        return BitmapFactory.decodeByteArray(photoBytes, 0, photoBytes.length, options);
    }

    private int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        // Calcule le facteur d'échantillonnage pour redimensionner l'image
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {
            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }

        return inSampleSize;
    }



    @Override
    public void onClick(View view) {
        int id = view.getId();

        if (id == R.id.ajoutassure_step4_droite_pouce) {
            doigt = 1;
            pouceDroit.setImageBitmap(null);
        }

        if (mCurrentDevice != null) {
            Log.i(TAG, "Click pouce droit");
            mCurrentDevice.captureSingle(
                    mCaptureOptionDefault,
                    mCaptureResponseDefault,
                    true);

        }
    }


}