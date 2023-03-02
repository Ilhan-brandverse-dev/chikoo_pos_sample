package com.brandverse.chikoo

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.os.RemoteException
import android.util.Log
import com.pos.intgr.service.AgPosIntgrServiceInterface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException

import org.json.JSONObject
import java.util.*
import java.util.concurrent.CompletableFuture


class MainActivity : FlutterActivity() {

    private val CHANNEL = "brandverse.chikoo/POS"

    var posService: AgPosIntgrServiceInterface? = null
    var connection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, iBinder: IBinder) {
            posService = AgPosIntgrServiceInterface.Stub.asInterface(iBinder)
            Log.d("AIDL SERVICE", "Remote config initialised")
        }

        override fun onServiceDisconnected(name: ComponentName) {}
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //AIDL BINDING
        bindToService()
        //INIT Method Channels
        flutterEngine?.dartExecutor?.let {
            MethodChannel(it.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "makePaymentCall" -> {
                        Log.d("====>>>", "PAYMENT CALL MADE")
                        val requestParams: String = call.argument<String>("data").toString()
                        val response = makePayment(requestParams)
                        result.success(response)
                    }
                    "checkPaymentStatus" -> {
                        Log.d("====>>", "PAYMENT STATUS CALL MADE")
                        val requestParams: String = call.argument<String>("data").toString()
                        val response = checkPaymentStatus(requestParams)
                        result.success(response)
                    }
                    "makePrinterCall" -> {
                        Log.d("====>>", "PRINTER CALL MADE")
                        val requestParams: String = call.argument<String>("data").toString()
                        val response = makePrinterCall(requestParams)
                        result.success(response)
                    }
                    "checkPrinterStatus" -> {
                        Log.d("====>>>", "PRINTER STATUS CALL MADE")
                        val requestParams: String = call.argument<String>("data").toString()
                        val response = checkPrinterStatus(requestParams)
                        result.success(response)
                    }
                    "getProcessId" -> {
                        val taskId = getProcessId()
                        Log.d("PROCESS ID", taskId.toString())
                        result.success(taskId)
                    }
                    else -> {
                        result.error("404", "NO SUCH METHOD", "METHOD TRYING TO CALL NOT EXISTS")
                    }
                }
            }
        }

    }

    private fun bindToService() {
        val intent = Intent("com.pos.intgr.service")
        intent.setPackage("com.pos.intgr.service")
        val check = bindService(
            intent,
            connection,
            BIND_AUTO_CREATE
        )
        if (check) {
            Log.d("Binding", "SUCCESSFUL")
        } else {
            Log.d("Binding", "FAILED")
        }

    }

    private fun makePayment(request: String): String? {
        Log.d("PAYMENT REQUEST", request)
        bindToService()

        val response = posService?.processPosRequest(request);
        if (response != null) {
            Log.d("PAYMENT RESPONSE", response)
        } else {
            Log.d("PAYMENT RESPONSE", "NOT RECEIVED")
        }
        return response;
    }


    private fun checkPaymentStatus(request: String): String? {
        Log.d("PAYMENT STATUS REQUEST", request)
        bindToService()
        var response = posService?.getStatus(request)
        if (response != null) {
            Log.d("PAYMENT STATUS RESPONSE", response)
        } else {
            Log.d("PAYMENT STATUS RESPONSE", "NOT RECEIVED")
        }
        return response
    }


    private fun makePrinterCall(request: String): String? {
        Log.d("PRINTER CALL", request)
        bindToService()
        val response = posService?.processPosRequest(request)
        if (response != null) {
            Log.d("PRINTER CALL RESPONSE", response)
        } else {
            Log.d("PRINTER CALL RESPONSE", "NOT RECEIVED")
        }
        return response
    }

    private fun checkPrinterStatus(request: String): String? {
        Log.d("PRINTER STATUS REQUEST", request)
        bindToService()
        val response = posService?.getStatus(request)

        if (response != null) {
            Log.d("PRINTER STATUS RESPONSE", response)
        } else {
            Log.d("PRINTER STATUS RESPONSE", "NOT RECEIVED")
        }
        return response;
    }


    private fun convertImplicitIntentToExplicitIntent(
        implicitIntent: Intent?,
        context: Context
    ): Intent? {
        val packageManager = context.packageManager
        val resolveInfoList = packageManager.queryIntentServices(
            implicitIntent!!, 0
        )
        if (resolveInfoList == null || resolveInfoList.size != 1) {
            return null
        }
        val serviceInfo = resolveInfoList[0]
        val component =
            ComponentName(serviceInfo.serviceInfo.packageName, serviceInfo.serviceInfo.name)
        val explicitIntent = Intent(implicitIntent)
        explicitIntent.component = component
        return explicitIntent
    }

    private fun getProcessId(): Int {
        val TAG = "PROCESS ID::-";
        var appId: Int = -1;
        try {
            val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            val recentTasks = activityManager.getRunningTasks(Int.MAX_VALUE)
            for (i in recentTasks.indices) {
                Log.e(
                    TAG,
                    "Application executed : " + recentTasks[i].baseActivity!!.toShortString() + "\t ID: " + recentTasks[i].id + ""
                )
                appId = recentTasks[0].id
                Log.d("APP ID ", appId.toString())
            }
            return appId;
        } catch (e: Exception) {
            Log.e(TAG, "onCreate: Catch")
            return -1;
        }
    }

}
