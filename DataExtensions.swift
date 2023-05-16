import Foundation
import zlib

extension Data {
    func gunzip() throws -> Data {
        var stream = z_stream()
        var status: Int32
        
        status = inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))

        if status != Z_OK {
            throw NSError(domain: "Zlib", code: Int(status), userInfo: nil)
        }

        var data = Data(count: self.count * 2)
        repeat {
            if Int(stream.total_out) >= data.count {
                data.count += self.count / 2
            }

            let inputCount = self.count
            let outputCount = data.count

            self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
                data.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                    stream.next_in = UnsafeMutablePointer(mutating: inputPointer.baseAddress!.assumingMemoryBound(to: UInt8.self))
                    stream.avail_in = uint(inputCount)
                    
                    stream.next_out = outputPointer.baseAddress?.assumingMemoryBound(to: UInt8.self).advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(data.count) - uInt(stream.total_out)
                    
                    status = zlib.inflate(&stream, Z_SYNC_FLUSH)
                }
            }
        } while status == Z_OK

        guard inflateEnd(&stream) == Z_OK, status == Z_STREAM_END else {
            throw NSError(domain: "Zlib", code: Int(status), userInfo: nil)
        }

        data.count = Int(stream.total_out)
        return data
    }
}

private func unzipEPG(fileURL: URL) throws -> Data {
    let compressedData = try Data(contentsOf: fileURL)
    let decompressedData = try compressedData.gunzip()
    return decompressedData
}
