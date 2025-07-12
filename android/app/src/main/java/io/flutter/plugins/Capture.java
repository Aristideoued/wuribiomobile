package io.flutter.plugins;

import android.content.Context;
import android.graphics.Bitmap;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;
import android.widget.ImageView;

import com.suprema.BioMiniFactory;
import com.suprema.CaptureResponder;
import com.suprema.IBioMiniDevice;

import java.util.HashMap;
import java.util.Iterator;

public class Capture {

    private final Context context;
    private final ImageView imageView;
    private final OnCaptureDoneListener listener;

    private IBioMiniDevice mCurrentDevice = null;
    private BioMiniFactory mBioMiniFactory;

    public interface OnCaptureDoneListener {
        void onCapture(Bitmap bitmap);
    }

    public Capture(Context context, ImageView imageView, OnCaptureDoneListener listener) {
        this.context = context;
        this.imageView = imageView;
        this.listener = listener;
        initFactory();
    }

    private void initFactory() {
        UsbManager usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
        mBioMiniFactory = new BioMiniFactory(context, usbManager) {
            @Override
            public void onDeviceChange(DeviceChangeEvent event, Object dev) {
                if (event == DeviceChangeEvent.DEVICE_ATTACHED) {
                    mCurrentDevice = mBioMiniFactory.getDevice(0);
                } else if (event == DeviceChangeEvent.DEVICE_DETACHED) {
                    mCurrentDevice = null;
                }
            }
        };

        // Vérifie les devices connectés
        HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
        Iterator<UsbDevice> deviceIterator = deviceList.values().iterator();
        while (deviceIterator.hasNext()) {
            UsbDevice device = deviceIterator.next();
            if (device.getVendorId() == 0x16d1) { // ID de Suprema
                usbManager.requestPermission(device, null); // null car pas besoin de PendingIntent ici
            }
        }
    }

    public void startCapture() {
        if (mCurrentDevice == null) {
            Log.e("FingerprintHelper", "Aucun capteur détecté");
            return;
        }

        mCurrentDevice.captureSingle(
                new IBioMiniDevice.CaptureOption(),
                new CaptureResponder() {
                    @Override
                    public boolean onCaptureEx(Object ctx, final Bitmap capturedImage,
                                               IBioMiniDevice.TemplateData data, IBioMiniDevice.FingerState state) {
                        if (capturedImage != null) {
                            imageView.setImageBitmap(capturedImage);
                            listener.onCapture(capturedImage);
                        }
                        return true;
                    }

                    @Override
                    public void onCaptureError(Object context, int errorCode, String error) {
                        Log.e("FingerprintHelper", "Erreur de capture : " + error);
                    }
                },
                true
        );
    }
}
